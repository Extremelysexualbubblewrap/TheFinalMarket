namespace :users do
  desc "Calculate user points and levels"
  task calculate_points: :environment do
    CalculateUserPointsJob.perform_now
  end
end