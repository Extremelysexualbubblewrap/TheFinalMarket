# app/services/square_payment_service.rb
class SquarePaymentService
  include Singleton

  def initialize
    @client = Square::Client.new(
      access_token: Rails.application.credentials.square[:access_token],
      environment: Rails.env.production? ? 'production' : 'sandbox'
    )
    @payments_api = @client.payments_api
    @refunds_api = @client.refunds_api
    @transfers_api = @client.transfers_api
  end

  def create_payment(transaction, nonce)
    begin
      result = @payments_api.create_payment(
        body: {
          source_id: nonce,
          amount_money: {
            amount: transaction.amount_cents,
            currency: 'USD'
          },
          idempotency_key: generate_idempotency_key(transaction),
          autocomplete: false, # Hold the payment for escrow
          note: transaction.description,
          reference_id: transaction.id.to_s,
          metadata: {
            order_id: transaction.order&.id.to_s,
            transaction_type: transaction.transaction_type
          }
        }
      )

      if result.success?
        transaction.update!(
          status: :held,
          square_payment_id: result.data.payment.id,
          processed_at: Time.current
        )
        
        NotificationService.notify(
          recipient: transaction.source_account.user,
          action: :payment_successful,
          notifiable: transaction.order
        )
      else
        handle_error(transaction, result.errors)
      end

      result.success?
    rescue StandardError => e
      handle_error(transaction, e)
      false
    end
  end

  def complete_payment(transaction)
    return false unless transaction.held?

    begin
      result = @payments_api.complete_payment(
        transaction.square_payment_id,
        body: { idempotency_key: generate_idempotency_key(transaction, 'complete') }
      )

      if result.success?
        transaction.update!(
          status: :completed,
          metadata: transaction.metadata.merge(completion_data: result.data.to_h)
        )
        true
      else
        handle_error(transaction, result.errors)
        false
      end
    rescue StandardError => e
      handle_error(transaction, e)
      false
    end
  end

  def refund_payment(transaction)
    return false unless transaction.order

    begin
      result = @refunds_api.refund_payment(
        body: {
          payment_id: transaction.order.payment_transactions.purchase.last.square_payment_id,
          amount_money: {
            amount: transaction.amount_cents,
            currency: 'USD'
          },
          idempotency_key: generate_idempotency_key(transaction, 'refund'),
          reason: transaction.metadata['reason']
        }
      )

      if result.success?
        transaction.update!(
          status: :completed,
          square_refund_id: result.data.refund.id,
          processed_at: Time.current
        )
        
        NotificationService.notify(
          recipient: transaction.source_account.user,
          action: :refund_processed,
          notifiable: transaction.order
        )
        true
      else
        handle_error(transaction, result.errors)
        false
      end
    rescue StandardError => e
      handle_error(transaction, e)
      false
    end
  end

  def transfer_to_seller(transaction)
    return false unless transaction.source_account.is_a?(SellerAccount)

    begin
      result = @transfers_api.create_transfer(
        body: {
          source_id: transaction.square_payment_id,
          destination_id: transaction.source_account.square_account_id,
          amount_money: {
            amount: transaction.amount_cents,
            currency: 'USD'
          },
          idempotency_key: generate_idempotency_key(transaction, 'transfer')
        }
      )

      if result.success?
        transaction.update!(
          status: :completed,
          square_transfer_id: result.data.transfer.id,
          processed_at: Time.current
        )
        
        NotificationService.notify(
          recipient: transaction.source_account.user,
          action: :payout_completed,
          notifiable: transaction
        )
        true
      else
        handle_error(transaction, result.errors)
        false
      end
    rescue StandardError => e
      handle_error(transaction, e)
      false
    end
  end

  private

  def generate_idempotency_key(transaction, action = nil)
    components = [
      transaction.id,
      transaction.created_at.to_i,
      action
    ].compact

    Digest::SHA256.hexdigest(components.join('-'))
  end

  def handle_error(transaction, error)
    error_details = error.is_a?(StandardError) ? error.message : error.map(&:detail).join(', ')
    
    transaction.update!(
      status: :failed,
      metadata: transaction.metadata.merge(error: error_details)
    )

    NotificationService.notify(
      recipient: transaction.source_account.user,
      action: :payment_failed,
      notifiable: transaction
    )

    Rails.logger.error("Square Payment Error for Transaction ##{transaction.id}: #{error_details}")
  end
end