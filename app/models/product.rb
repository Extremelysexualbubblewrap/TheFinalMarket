class Product < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :user
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :product_tags, dependent: :destroy
  has_many :tags, through: :product_tags
  has_many :product_images, -> { order(position: :asc) }, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :reviewers, through: :reviews, source: :user

  # Elasticsearch configuration
  settings index: {
    number_of_shards: 1,
    number_of_replicas: 0,
    analysis: {
      analyzer: {
        custom_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: ['lowercase', 'custom_stemmer', 'custom_synonym']
        }
      },
      filter: {
        custom_stemmer: {
          type: 'stemmer',
          language: 'english'
        },
        custom_synonym: {
          type: 'synonym',
          synonyms: [
            'laptop, notebook',
            'phone, smartphone, mobile',
            'tv, television',
            'headphone, headset',
            'tablet, ipad'
          ]
        }
      }
    }
  }

  # Define Elasticsearch mapping
  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name price brand created_at updated_at status availability]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[categories tags reviews user]
  end

  mapping dynamic: 'false' do
    indexes :name, type: 'text', analyzer: 'custom_analyzer' do
      indexes :keyword, type: 'keyword'
    end
    indexes :description, type: 'text', analyzer: 'custom_analyzer'
    indexes :price, type: 'double'
    indexes :category, type: 'keyword'
    indexes :brand, type: 'keyword'
    indexes :tags, type: 'keyword'
    indexes :average_rating, type: 'float'
    indexes :total_reviews, type: 'integer'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
    indexes :variants do
      indexes :sku, type: 'keyword'
      indexes :price, type: 'double'
      indexes :stock_quantity, type: 'integer'
    end
  end

  accepts_nested_attributes_for :product_images, allow_destroy: true, reject_if: :all_blank
  
  has_many :option_types, dependent: :destroy
  has_many :option_values, through: :option_types
  has_many :variants, dependent: :destroy
  
  accepts_nested_attributes_for :option_types, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :variants, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 1000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  after_create :create_default_variant

  def tag_list
    tags.pluck(:name).join(', ')
  end

  def tag_list=(names)
    self.tags = names.split(',').map do |name|
      Tag.where(name: name.strip.downcase).first_or_create!
    end
  end

  def default_variant
    variants.first || variants.build(price: price, stock_quantity: 0)
  end

  def available_variants
    variants.where(active: true).order(:price)
  end

  def has_variants?
    variants.count > 1
  end

  def min_price
    variants.minimum(:price)
  end

  # Elasticsearch methods
  def as_indexed_json(options = {})
    {
      name: name,
      description: description,
      price: price,
      category: categories.pluck(:name),
      brand: user.brand_name,
      tags: tags.pluck(:name),
      average_rating: reviews.average(:rating)&.round(2) || 0.0,
      total_reviews: reviews.count,
      created_at: created_at,
      updated_at: updated_at,
      variants: variants.map { |v| 
        {
          sku: v.sku,
          price: v.price,
          stock_quantity: v.stock_quantity
        }
      }
    }
  end

  def self.search_with_analytics(query: nil, filters: {}, page: 1, per_page: 20, user: nil)
    search_results = AdvancedSearchService.new(
      query: query,
      filters: filters,
      page: page,
      per_page: per_page
    ).search

    # Track search analytics if user is present
    if user.present?
      Ahoy::Event.create(
        name: "product_search",
        properties: {
          query: query,
          filters: filters,
          results_count: search_results[:total],
          page: page
        },
        user: user
      )
    end

    # Update search suggestions based on successful searches
    if search_results[:total] > 0
      Rails.cache.write(
        "search_suggestions:#{query.downcase}",
        search_results[:suggestions],
        expires_in: 1.week
      )
    end

    search_results
  end

  def max_price
    variants.maximum(:price)
  end

  def total_stock
    variants.sum(:stock_quantity)
  end

  private

  def create_default_variant
    variants.create!(price: price, stock_quantity: 0, name: 'Default')
  end
end
