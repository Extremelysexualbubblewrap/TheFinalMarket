# app/controllers/webhooks/square_controller.rb
module Webhooks
  class SquareController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :verify_square_webhook

    WEBHOOK_SIGNATURE_KEY = Rails.application.credentials.square[:webhook_signature_key]

    def receive
      case webhook_type
      when 'payment.updated'
        process_payment_update
      when 'payment.refunded'
        process_refund_update
      when 'transfer.paid'
        process_transfer_update
      end

      head :ok
    end

    private

    def verify_square_webhook
      signature = request.headers['X-Square-Signature']
      unless signature && verify_signature(signature, request.raw_post)
        head :unauthorized
        return
      end
    end

    def verify_signature(signature, payload)
      expected = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        WEBHOOK_SIGNATURE_KEY,
        payload
      )
      
      ActiveSupport::SecurityUtils.secure_compare(signature, expected)
    end

    def webhook_type
      @webhook_type ||= request.headers['X-Square-Event-Type']
    end

    def webhook_data
      @webhook_data ||= JSON.parse(request.raw_post)
    end

    def process_payment_update
      payment = webhook_data['data']['object']['payment']
      transaction = PaymentTransaction.find_by(square_payment_id: payment['id'])
      
      return unless transaction

      if payment['status'] == 'COMPLETED'
        if transaction.transaction_type == 'purchase' && transaction.order&.ready_for_escrow?
          # Start escrow countdown
          CheckEscrowExpiryJob.set(wait: Rails.configuration.escrow_expiry_days.days)
                             .perform_later(transaction.order_id)
        end
        
        transaction.update!(status: :completed)
      elsif payment['status'] == 'FAILED'
        transaction.update!(
          status: :failed,
          metadata: transaction.metadata.merge(error: payment['status_details'])
        )
      end
    end

    def process_refund_update
      refund = webhook_data['data']['object']['refund']
      transaction = PaymentTransaction.find_by(square_refund_id: refund['id'])
      
      return unless transaction

      if refund['status'] == 'COMPLETED'
        transaction.update!(status: :completed)
      elsif refund['status'] == 'FAILED'
        transaction.update!(
          status: :failed,
          metadata: transaction.metadata.merge(error: refund['status_details'])
        )
      end
    end

    def process_transfer_update
      transfer = webhook_data['data']['object']['transfer']
      transaction = PaymentTransaction.find_by(square_transfer_id: transfer['id'])
      
      return unless transaction

      if transfer['status'] == 'PAID'
        transaction.update!(status: :completed)
      elsif transfer['status'] == 'FAILED'
        transaction.update!(
          status: :failed,
          metadata: transaction.metadata.merge(error: transfer['status_details'])
        )
      end
    end
  end
end