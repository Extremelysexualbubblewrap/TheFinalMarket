# app/models/concerns/square_account.rb
module SquareAccount
  extend ActiveSupport::Concern

  included do
    validates :square_account_id, uniqueness: true, allow_nil: true
    
    before_validation :ensure_square_account, on: :create
  end

  def square_enabled?
    square_account_id.present?
  end

  private

  def ensure_square_account
    return if square_account_id.present?

    begin
      # Create Square customer/merchant account
      result = Square::Client.new.customers_api.create_customer(
        body: {
          idempotency_key: SecureRandom.uuid,
          email_address: user.email,
          given_name: user.first_name,
          family_name: user.last_name,
          reference_id: id.to_s,
          company_name: merchant_name
        }
      )

      if result.success?
        self.square_account_id = result.data.customer.id
      else
        errors.add(:square_account_id, result.errors.map(&:detail).join(', '))
      end
    rescue StandardError => e
      errors.add(:square_account_id, e.message)
    end
  end
end