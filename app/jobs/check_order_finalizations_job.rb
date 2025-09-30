class CheckOrderFinalizationsJob < ApplicationJob
  queue_as :default

  def perform
    OrderFinalizationService.check_pending_finalizations
  end

  def self.schedule
    set(wait: 1.hour).perform_later
  end
end