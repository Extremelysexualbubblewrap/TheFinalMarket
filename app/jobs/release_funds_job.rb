class ReleaseFundsJob < ApplicationJob
  queue_as :payments

  def perform(escrow_transaction)
    # Call Square API to transfer funds to seller's account
    seller_account = escrow_transaction.seller_account
    payment_service = SquarePaymentService.new

    result = payment_service.transfer_to_seller(
      amount: escrow_transaction.amount,
      destination_account_id: seller_account.square_account_id,
      source_transaction_id: escrow_transaction.payment_transaction.square_payment_id,
      idempotency_key: "release_#{escrow_transaction.id}"
    )

    if result.success?
      # Record transfer ID and mark as released
      escrow_transaction.payment_transaction.update!(square_transfer_id: result.transfer_id)
      escrow_transaction.complete_release!

      # Notify seller
      NotificationService.notify(
        user: escrow_transaction.seller_account.user,
        title: "Payment Released",
        body: "Payment of #{escrow_transaction.amount.format} has been released to your account."
      )
    else
      # Log error and retry
      Rails.logger.error("Failed to release funds for escrow transaction #{escrow_transaction.id}: #{result.error}")
      raise result.error # This will trigger a retry based on Active Job's retry mechanism
    end
  end

  retry_on StandardError, wait: :exponentially_longer, attempts: 3
end