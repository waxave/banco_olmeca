# frozen_string_literal: true

module CardsHelper
  def display_card(card_number)
    return '0000-0000-0000-0000' unless card_number.present?

    card_number.scan(/.{1,4}/).join('-')
  end
end
