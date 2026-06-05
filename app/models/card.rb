# == Schema Information
#
# Table name: cards
#
#  id               :bigint           not null, primary key
#  balance          :decimal(, )
#  cvv              :integer
#  default          :boolean
#  expiration_month :integer
#  expiration_year  :integer
#  kind             :integer
#  number           :string(16)
#  pin              :integer
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#
# Indexes
#
#  index_cards_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Card < ApplicationRecord
  ERRORS = {
    card_not_found: 'Card not found'
  }.freeze

  belongs_to :account

  validates :pin, presence: true, length: { is: 4 }

  attribute :balance, :decimal, default: 250_000
  enum :kind, %i[debit credit], default: :debit
  enum :status, %i[enabled disabled], default: :enabled
  attribute :default, :boolean, default: false

  before_create :number_assignation
  before_create :cvv_assignation
  before_create :expiration_month_assignation
  before_create :expiration_year_assignation
  before_create :assign_as_default

  def as_json(options = {})
    options[:except] ||= %i[pin cvv]
    super
  end

  private

  def number_assignation
    self.number = number_generator
  end

  def cvv_assignation
    self.cvv = digit_generator(3)
  end

  def expiration_month_assignation
    random_month = rand(1..12)
    self.expiration_month = random_month
  end

  def expiration_year_assignation
    year = Date.today.year + 5
    self.expiration_year = year
  end

  def assign_as_default
    first_card = Card.where(account_id:, default: true)

    self.default = first_card.blank?
  end

  def number_generator
    "#{digit_generator(4)}#{digit_generator(4)}#{digit_generator(4)}#{digit_generator(4)}"
  end

  def digit_generator(size)
    zero_ascii_char_code = '0'.ord
    nine_ascii_char_code = '9'.ord

    (0...size).map { rand(zero_ascii_char_code..nine_ascii_char_code).chr }.join
  end
end
