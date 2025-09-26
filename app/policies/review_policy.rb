class ReviewPolicy < ApplicationPolicy
  def create?
    user.present? && record.product.user != user && !record.product.reviews.exists?(user: user)
  end

  def destroy?
    user.admin? || record.user == user
  end
end