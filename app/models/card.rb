class Card < ApplicationRecord
  belongs_to :account

  validates :cvv, presence: true, length: { is: 3 }
  validates :pin, presence: true, length: { is: 4 }

  attribute :balance, :decimal, default: 0
  enum :kind, %i[debit credit], default: :debit
  enum :status, %i[enabled disabled], default: :enabled
  attribute :default, :boolean, default: true
end
