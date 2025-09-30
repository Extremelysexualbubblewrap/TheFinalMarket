# app/mailers/review_mailer.rb
class ReviewMailer < ApplicationMailer
  def invitation_email
    @review_invitation = params[:review_invitation]
    @user = @review_invitation.user
    @item = @review_invitation.item
    @order = @review_invitation.order

    mail(
      to: @user.email,
      subject: "Review your purchase from #{@item.user.name}"
    )
  end
end