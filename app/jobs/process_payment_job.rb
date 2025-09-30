# app/jobs/process_payment_job.rb
class ProcessPaymentJob < ApplicationJob
  queue_as :payments

  def perform(transaction_id, payment_nonce)
    transaction = PaymentTransaction.find(transaction_id)
    
    return if transaction.processed?

    success = SquarePaymentService.instance.create_payment(transaction, payment_nonce)

    if success && transaction.order&.ready_for_escrow?
      CheckEscrowExpiryJob.set(wait: Rails.configuration.escrow_expiry_days.days)
                         .perform_later(transaction.order_id)
    end
  end
end