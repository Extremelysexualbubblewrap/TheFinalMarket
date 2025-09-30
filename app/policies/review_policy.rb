class ReviewPolicy < ApplicationPolicy
  def create?
    return false unless user
    return true if review_invitation_valid?
    return true if user.admin?
    
    if record.reviewable.is_a?(Item)
      verify_item_purchase
    elsif record.reviewable.is_a?(User)
      verify_user_transaction
    else
      false
    end
  end

  def update?
    return false unless user
    user == record.reviewer || user.admin?
  end

  def destroy?
    return false unless user
    user == record.reviewer || user.admin? || user.moderator?
  end

  def helpful?
    return false unless user
    user != record.reviewer && !user.helpful_votes.exists?(review: record)
  end

  private

  def review_invitation_valid?
    return false unless record.review_invitation
    
    invitation = record.review_invitation
    invitation.user == user && invitation.pending? && !invitation.expired?
  end

  def verify_item_purchase
    user.orders.completed.joins(:order_items)
        .where(order_items: { item_id: record.reviewable_id })
        .exists?
  end

  def verify_user_transaction
    # Can review a seller if you've completed a purchase from them
    seller = record.reviewable
    user.orders.completed.joins(:order_items)
        .where(order_items: { item: { user_id: seller.id } })
        .exists?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end