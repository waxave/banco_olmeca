# frozen_string_literal: true

module ApplicationHelper
  def page
    page_title = find_page_title(request.path)
    page_title || 'Dashboard'
  end

  def format_operation_date(date)
    return unless date

    if date > 24.hours.ago
      time_ago_in_words_i18n(date)
    else
      date.strftime('%d/%m/%Y %H:%M')
    end
  end

  def operation_target_info(operation)
    if operation.operationable == operation.account
      t('operations.main_account')
    else
      case operation.operationable_type
      when 'Account'
        account = operation.operationable
        t('operations.target_info.account', name: account.name, email: account.email)
      when 'Card'
        card = operation.operationable
        t('operations.target_info.card', number: display_card(card.number))
      else
        t('operations.target_info.unknown')
      end
    end
  end

  def time_ago_in_words_i18n(time)
    seconds_ago = Time.current - time

    if seconds_ago < 60
      t('operations.time_ago.less_than_minute')
    elsif seconds_ago < 3600
      minutes = (seconds_ago / 60).round
      t('operations.time_ago.x_minutes', count: minutes)
    elsif seconds_ago < 86_400
      hours = (seconds_ago / 3600).round
      if hours < 24
        t('operations.time_ago.about_x_hours', count: hours)
      else
        t('operations.time_ago.x_hours', count: hours)
      end
    elsif seconds_ago < 2_592_000
      days = (seconds_ago / 86_400).round
      t('operations.time_ago.x_days', count: days)
    else
      t('operations.time_ago.unknown')
    end
  rescue StandardError
    t('operations.time_ago.unknown')
  end

  def menu_link(path, text)
    current_path = path == request.path
    active_classes = 'bg-[#1A5B61] text-white rounded-md px-3 py-2 text-sm font-bold'
    default_classes = 'text-[#1A5B61] hover:bg-[#1A5B61] hover:text-white rounded-md px-3 py-2 text-sm font-bold'
    content_tag(:a, text, href: path, class: current_path ? active_classes : default_classes)
  end

  private

  def find_page_title(path)
    return 'Dashboard' if path == root_path
    return 'New Transfer' if path == new_transfer_path
    return 'New Deposit' if path == new_deposit_path
    return 'New Withdrawal' if path == new_withdraw_path
  end
end
