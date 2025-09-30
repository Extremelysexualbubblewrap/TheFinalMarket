# app/jobs/process_refund_job.rb
class ProcessRefundJob < ApplicationJob
  queue_as :payments
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(transaction)
    return if transaction.completed? || transaction.processing?

    transaction.update!(status: :processing)
    SquarePaymentService.instance.refund_payment(transaction)
  end
end
end