# frozen_string_literal: true

class CardCreationJob < ApplicationJob
  queue_as :default

  DEFAULT_PIN = 9999

  def perform(account_id)
    Account.find(account_id)

    # Crear tarjeta de débito
    Card.create(account_id:, pin: DEFAULT_PIN, kind: :debit)

    # Crear dos tarjetas de crédito
    Card.create(account_id:, pin: DEFAULT_PIN, kind: :credit)
    Card.create(account_id:, pin: DEFAULT_PIN, kind: :credit)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Account not found for card creation: #{e.message}"
    raise e
  end
end
