module ContentFilterable
  extend ActiveSupport::Concern

  included do
    before_validation :check_content_filter, if: :should_filter_content?
  end

  private

  def check_content_filter
    filtered_fields.each do |field|
      content = send(field)
      next unless content.is_a?(String) && content.present?

      if ContentFilter.should_flag?(content)
        errors.add(field, "contains inappropriate or spam content")
      end
    end
  end

  def should_filter_content?
    respond_to?(:filtered_fields) && filtered_fields.any?
  end
end