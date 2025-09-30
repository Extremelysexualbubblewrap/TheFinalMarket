class DisputeResolutionService
  def initialize(dispute, admin_user)
    @dispute = dispute
    @admin_user = admin_user
  end

  def resolve(resolution)
    case resolution
    when 'refund_buyer'
      refund_buyer
    when 'release_to_seller'
      release_to_seller
    else
      false
    end
  end

  private

  def refund_buyer
    escrow_transaction = @dispute.escrow_transaction
    return false unless escrow_transaction

    # Use the RefundFundsJob to process the refund
    RefundFundsJob.perform_later(escrow_transaction)
    @dispute.update(status: :resolved, resolved_at: Time.current)
    true
  end

  def release_to_seller
    escrow_transaction = @dispute.escrow_transaction
    return false unless escrow_transaction

    # Use the ReleaseFundsJob to process the release
    ReleaseFundsJob.perform_later(escrow_transaction)
    @dispute.update(status: :resolved, resolved_at: Time.current)
    true
  end
end
