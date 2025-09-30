module SellerBondConcern
  extend ActiveSupport G.concern

  included do
    has_one :bond

    after_save :update_bond_status, if: :saved_change_to_bond_id?
  end

  def bond_active?
    bond_status == 'active'
  end

  def bond_pending?
    bond_status == 'pending'
  end

  def no_bond?
    bond_status == 'none'
  end

  private

  def update_bond_status
    new_status = bond&.status || 'none'
    update_column(:bond_status, new_status)
  end
end
