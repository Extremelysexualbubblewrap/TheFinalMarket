class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image
  has_one_attached :thumbnail

  validates :image, presence: true
  validate :acceptable_image

  after_create :generate_thumbnail

  # Position handling for ordering images
  acts_as_list scope: :product

  private

  def acceptable_image
    return unless image.attached?

    unless image.blob.byte_size <= 10.megabytes
      errors.add(:image, "is too big (should be less than 10MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/webp"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, or WEBP")
    end
  end

  def generate_thumbnail
    return unless image.attached?

    # Generate and attach thumbnail
    thumbnail_path = image.blob.service.send(:path_for, image.key)
    processed_thumbnail = MiniMagick::Image.open(thumbnail_path)
    processed_thumbnail.resize "300x300>"
    
    # Create a temporary file for the processed thumbnail
    temp_file = Tempfile.new(['thumbnail', '.jpg'])
    processed_thumbnail.write(temp_file.path)
    
    # Attach the processed thumbnail
    thumbnail.attach(
      io: File.open(temp_file.path),
      filename: "thumbnail_#{image.filename}",
      content_type: 'image/jpeg'
    )
  ensure
    temp_file&.close
    temp_file&.unlink
  end
end