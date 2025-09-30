# app/jobs/process_payout_job.rb
class ProcessPayoutJob < ApplicationJob
  queue_as :payments
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(transaction)
    return if transaction.completed? || transaction.processing?

    transaction.update!(status: :processing)
    SquarePaymentService.instance.transfer_to_seller(transaction)
  end
end
end