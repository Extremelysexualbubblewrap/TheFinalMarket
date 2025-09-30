class UpdateSellerStatsJob < ApplicationJob
  queue_as :default

  def perform(seller = nil)
    if seller
      SellerStatsService.update_stats(seller)
    else
      # Update all sellers who haven't been updated in the last 24 hours
      User.seller
          .where('last_sales_update IS NULL OR last_sales_update < ?', 24.hours.ago)
          .find_each do |seller|
        SellerStatsService.update_stats(seller)
      end
    end
  end
end