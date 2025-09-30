class ProcessEscrowReleasesJob < ApplicationJob
  queue_as :payments

  def perform
    EscrowService.process_pending_releases
  end
end