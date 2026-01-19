class CardCreationJob < ApplicationJob
  queue_as :default

  def perform(account_id)
    Account.find(account_id)

    # Crear tarjeta de débito
    Card.create(account_id:, pin: 9999, kind: :debit)

    # Crear dos tarjetas de crédito
    Card.create(account_id:, pin: 9999, kind: :credit)
    Card.create(account_id:, pin: 9999, kind: :credit)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Account not found for card creation: #{e.message}"
    raise e
  end
end
