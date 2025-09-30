module MessagesHelper
  def message_bubble_classes(message)
    base_classes = "rounded-lg p-3 break-words"
    
    if message.user == current_user
      case message.message_type
      when 'system'
        "#{base_classes} bg-gray-100 text-gray-600"
      else
        "#{base_classes} bg-blue-500 text-white"
      end
    else
      "#{base_classes} bg-white border border-gray-200"
    end
  end
end