class AdminApprovalService
  def initialize(admin, resource)
    @admin = admin
    @resource = resource
    @transaction = nil
  end

  def approve(action:, reason:)
    return false unless @admin.admin?

    ApplicationRecord.transaction do
      create_admin_transaction(action, reason)
      process_approval
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Admin approval failed: #{e.message}")
    false
  end

  private

  def create_admin_transaction(action, reason)
    @transaction = AdminTransaction.create!(
      admin: @admin,
      approvable: @resource,
      action: action,
      reason: reason
    )
  end

  def process_approval
    case @resource
    when EscrowTransaction
      process_escrow_approval
    when Order
      process_order_approval
    when Dispute
      process_dispute_approval
    else
      raise ArgumentError, "Unsupported resource type: #{@resource.class}"
    end
  end

  def process_escrow_approval
    case @transaction.action
    when 'escrow_release'
      @resource.release_funds(admin_approved: true)
    when 'escrow_refund'
      @resource.refund(admin_approved: true)
    else
      raise ArgumentError, "Invalid action for escrow: #{@transaction.action}"
    end
  end

  def process_order_approval
    if @transaction.action == 'order_finalization'
      @resource.finalize(admin_approved: true)
    else
      raise ArgumentError, "Invalid action for order: #{@transaction.action}"
    end
  end

  def process_dispute_approval
    if @transaction.action == 'dispute_resolution'
      resolution_params = @transaction.details['resolution'] || {}
      @resource.resolve(resolution_params.merge(admin_approved: true))
    else
      raise ArgumentError, "Invalid action for dispute: #{@transaction.action}"
    end
  end
end