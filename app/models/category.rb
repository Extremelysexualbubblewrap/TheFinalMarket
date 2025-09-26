class Category < ApplicationRecord
  # Associations for hierarchical structure
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  
  # Item associations
  has_many :items, dependent: :restrict_with_error
  has_many :all_items, through: :descendants, source: :items

  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id, case_sensitive: false }
  validates :name, length: { minimum: 2, maximum: 50 }
  validates :description, length: { maximum: 500 }
  validate :prevent_circular_dependency

  # Scopes
  scope :main_categories, -> { where(parent_id: nil) }
  scope :active, -> { where(active: true) }
  scope :with_items, -> { joins(:items).distinct }

  before_save :normalize_name

  def ancestors
    return [] if parent_id.nil?
    parent.ancestors + [parent]
  end

  def descendants
    subcategories.flat_map { |subcat| [subcat] + subcat.descendants }
  end

  def full_name
    ancestors.map(&:name).push(name).join(" > ")
  end

  def root?
    parent_id.nil?
  end

  def leaf?
    subcategories.empty?
  end

  def siblings
    parent ? parent.subcategories.where.not(id: id) : Category.main_categories.where.not(id: id)
  end

  def self.tree
    main_categories.includes(:subcategories)
  end

  private

  def normalize_name
    self.name = name.strip.titleize
  end

  def prevent_circular_dependency
    if parent_id_changed? && descendants.include?(self)
      errors.add(:parent_id, "would create a circular dependency")
    end
  end
end
