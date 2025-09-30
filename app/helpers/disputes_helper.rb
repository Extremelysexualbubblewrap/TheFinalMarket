module DisputesHelper
  def resolution_status_classes(resolution_type)
    case resolution_type
    when 'buyer_refund'
      'bg-yellow-100 text-yellow-800'
    when 'seller_release'
      'bg-green-100 text-green-800'
    when 'split_payment'
      'bg-blue-100 text-blue-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end

  def can_add_evidence?(dispute)
    return false if dispute.resolved?
    current_user == dispute.order.user || 
    current_user == dispute.order.seller ||
    current_user&.moderator?
  end
end
