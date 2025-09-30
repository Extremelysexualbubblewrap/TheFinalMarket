class RefundFundsJob < ApplicationJob
  queue_as :payments

  def perform(escrow_transaction)
    # Call Square API to refund the payment
    payment_service = SquarePaymentService.new

    result = payment_service.refund_payment(
      amount: escrow_transaction.amount,
      payment_id: escrow_transaction.payment_transaction.square_payment_id,
      idempotency_key: "refund_#{escrow_transaction.id}"
    )

    if result.success?
      # Record refund ID and mark as refunded
      escrow_transaction.payment_transaction.update!(square_refund_id: result.refund_id)
      escrow_transaction.complete_refund!

      # Notify buyer
      NotificationService.notify(
        user: escrow_transaction.buyer_account.user,
        title: "Refund Processed",
        body: "A refund of #{escrow_transaction.amount.format} has been processed to your payment method."
      )
    else
      # Log error and retry
      Rails.logger.error("Failed to process refund for escrow transaction #{escrow_transaction.id}: #{result.error}")
      raise result.error # This will trigger a retry based on Active Job's retry mechanism
    end
  end

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
end