# app/jobs/expire_review_invitations_job.rb
class ExpireReviewInvitationsJob < ApplicationJob
  queue_as :default

  def perform
    ReviewInvitation.pending.expired.find_each do |invitation|
      invitation.expire!
    end
  end
end