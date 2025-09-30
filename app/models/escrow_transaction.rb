class EscrowTransaction < ApplicationRecord
  belongs_to :escrow_wallet
  belongs_to :order
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  enum status: {
    pending: 0,
    held: 1,
    released: 2,
    refunded: 3,
    disputed: 4,
    partially_refunded: 5
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :transaction_type, presence: true

  scope :pending_finalization, -> { where(status: :held).where('created_at <= ?', 7.days.ago) }
  scope :needs_admin_approval, -> { where(status: :held, needs_admin_approval: true) }

  def hold_funds
    if escrow_wallet.hold_funds(amount)
      update(status: :held)
      notify_parties("Funds held in escrow")
      true
    else
      errors.add(:base, "Insufficient funds")
      false
    end
  end

  def release_funds(admin_approved: false)
    return false unless can_release_funds?(admin_approved)

    transaction do
      receiver.escrow_wallet.receive_funds(amount)
      escrow_wallet.release_funds(amount)
      update(status: :released, admin_approved_at: admin_approved ? Time.current : nil)
      notify_parties("Funds released to seller")
    end
    true
  rescue => e
    errors.add(:base, "Failed to release funds: #{e.message}")
    false
  end

  def refund(refund_amount = nil, admin_approved: false)
    return false unless can_refund?(admin_approved)

    refund_amount ||= amount
    transaction do
      sender.escrow_wallet.receive_funds(refund_amount)
      escrow_wallet.release_funds(refund_amount)
      
      if refund_amount == amount
        update(status: :refunded)
      else
        update(status: :partially_refunded, refunded_amount: refund_amount)
      end
      
      notify_parties("Refund processed: #{refund_amount}")
    end
    true
  rescue => e
    errors.add(:base, "Failed to process refund: #{e.message}")
    false
  end

  def initiate_dispute
    return false if disputed?
    
    transaction do
      update(status: :disputed)
      dispute = order.create_dispute!(
        buyer: sender,
        seller: receiver,
        amount: amount,
        escrow_transaction: self
      )
      notify_parties("Dispute initiated")
      DisputeAssignmentService.new(dispute).assign_mediator
    end
    true
  rescue => e
    errors.add(:base, "Failed to initiate dispute: #{e.message}")
    false
  end

  private

  def can_release_funds?(admin_approved)
    return false unless held?
    return true if admin_approved
    return false if needs_admin_approval && !admin_approved
    true
  end

  def can_refund?(admin_approved)
    return false unless held? || disputed?
    return true if admin_approved
    return false if needs_admin_approval && !admin_approved
    true
  end

  def notify_parties(message)
    [sender, receiver].each do |user|
      NotificationService.notify(
        user: user,
        title: "Escrow Update",
        message: message,
        resource: self
      )
    end
  end
end