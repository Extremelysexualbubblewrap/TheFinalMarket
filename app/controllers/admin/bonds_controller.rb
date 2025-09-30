class Admin::BondsController < Admin::BaseController
  before_action :set_bond, only: [:show, :approve, :forfeit]

  def index
    @bonds = Bond.includes(:user).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def approve
    if @bond.active?
      redirect_to admin_bond_path(@bond), alert: 'Bond is already active.'
    else
      # This would typically involve verifying the payment, but for now we'll just activate it.
      @bond.update(status: :active, paid_at: Time.current)
      redirect_to admin_bond_path(@bond), notice: 'Bond has been approved and activated.'
    end
  end

  def forfeit
    if @bond.forfeited?
      redirect_to admin_bond_path(@bond), alert: 'Bond has already been forfeited.'
    else
      reason = params.dig(:bond, :forfeiture_reason)
      if reason.blank?
        redirect_to admin_bond_path(@bond), alert: 'A reason is required to forfeit a bond.'
      else
        BondService.new(@bond.user).forfeit_bond(@bond, reason)
        redirect_to admin_bond_path(@bond), notice: 'Bond has been forfeited.'
      end
    end
  end

  private

  def set_bond
    @bond = Bond.find(params[:id])
  end
end
