module ApplicationHelper
  def page
    case request.path
    when root_path
      'Dashboard'
    when new_transfer_path
      'New Transfer'
    when new_deposit_path
      'New Deposit'
    when new_withdraw_path
      'New Withdrawal'
    else
      'Dashboard'
    end
  end

  def display_card(card_number)
    return '0000-0000-0000-0000' unless card_number.present?

    card_number.scan(/.{1,4}/).join('-')
  end

  def menu_link(path, text)
    current_path = path == request.path
    active_classes = 'bg-[#1A5B61] text-white rounded-md px-3 py-2 text-sm font-bold'
    default_classes = 'text-[#1A5B61] hover:bg-[#1A5B61] hover:text-white rounded-md px-3 py-2 text-sm font-bold'
    content_tag(:a, text, href: path, class: current_path ? active_classes : default_classes)
  end
end
