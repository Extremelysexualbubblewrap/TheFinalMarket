# app/jobs/process_purchase_job.rb
class ProcessPurchaseJob < ApplicationJob
  queue_as :payments
  retry_on Stripe::StripeError, wait: :exponentially_longer, attempts: 3

  def perform(transaction)
    return if transaction.completed? || transaction.processing?

    transaction.update!(status: :processing)

    begin
      charge = Stripe::Charge.create(
        amount: transaction.amount_cents,
        currency: 'usd',
        customer: transaction.source_account.stripe_customer_id,
        description: transaction.description,
        metadata: {
          order_id: transaction.order&.id,
          transaction_id: transaction.id
        }
      )

      transaction.update!(
        status: :completed,
        stripe_transaction_id: charge.id,
        processed_at: Time.current
      )

      NotificationService.notify(
        recipient: transaction.source_account.user,
        action: :payment_successful,
        notifiable: transaction.order
      )
    rescue Stripe::StripeError => e
      transaction.update!(
        status: :failed,
        metadata: transaction.metadata.merge(error: e.message)
      )

      NotificationService.notify(
        recipient: transaction.source_account.user,
        action: :payment_failed,
        notifiable: transaction.order
      )

      raise e
    end
  end
end