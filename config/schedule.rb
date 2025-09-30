# config/schedule.rb
every 1.day, at: '4:30 am' do
  runner "ExpireReviewInvitationsJob.perform_later"
end

# Process escrow releases every hour
every 1.hour do
  runner "ProcessEscrowReleasesJob.perform_later"
end

# Update seller statistics
every 6.hours do
  runner "UpdateSellerStatsJob.perform_later"
end