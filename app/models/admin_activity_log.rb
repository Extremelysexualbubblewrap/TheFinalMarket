class AdminActivityLog < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  belongs_to :resource, polymorphic: true
  
  serialize :details, JSON
  
  validates :action, presence: true
  validates :details, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_admin, ->(admin) { where(admin: admin) }
  scope :by_action, ->(action) { where(action: action) }
  scope :today, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  
  def self.action_types
    %w[
      escrow_release
      escrow_refund
      dispute_resolution
      order_finalization
      account_suspension
      other
    ]
  end
  
  validates :action, inclusion: { in: action_types }
end