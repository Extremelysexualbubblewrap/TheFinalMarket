class Tag < ApplicationRecord
  has_many :product_tags, dependent: :destroy
  has_many :products, through: :product_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  before_save :normalize_name

  private

  def normalize_name
    self.name = name.downcase.strip
  end
end