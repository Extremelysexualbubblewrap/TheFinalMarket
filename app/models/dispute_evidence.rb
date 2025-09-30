class DisputeEvidence < ApplicationRecord
  belongs_to :dispute
  belongs_to :user

  has_one_attached :attachment

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 500 }
  validates :attachment, presence: true
  
  validate :acceptable_attachment_type
  validate :acceptable_attachment_size
  
  private
  
  def acceptable_attachment_type
    return unless attachment.attached?
    
    acceptable_types = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 
                       'video/mp4', 'video/quicktime']
    
    unless attachment.content_type.in?(acceptable_types)
      errors.add(:attachment, 'must be an image, PDF, or video file')
    end
  end
  
  def acceptable_attachment_size
    return unless attachment.attached?
    
    max_size = 50.megabytes
    
    if attachment.byte_size > max_size
      errors.add(:attachment, "size must be less than #{max_size}")
    end
  end
end