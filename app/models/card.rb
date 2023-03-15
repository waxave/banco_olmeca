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
  before_create :assing_as_default
  after_create :create_default_operations

  scope :for_operation, ->(query) { where('number = ?', query.to_s).take(1) }
  scope :auth, ->(number, pin) { where('number = ? AND pin = ?', number.to_s, pin).take(1) }

  def as_json(options = {})
    options[:except] ||= %i[pin cvv]
    super(options)
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

  def assing_as_default
    first_card = Card.where(account_id: account_id, default: true)

    self.default = first_card.present? ? false : true
  end

  def number_generator
    "#{digit_generator(4)}#{digit_generator(4)}#{digit_generator(4)}#{digit_generator(4)}"
  end

  def digit_generator(size)
    zero_ascii_char_code = '0'.ord
    nine_ascii_char_code = '9'.ord

    (0...size).map { rand(zero_ascii_char_code..nine_ascii_char_code).chr }.join
  end

  def create_default_operations
    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :deposit,
      amount: 4000,
      concept: 'new deposit'
    )

    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :deposit,
      amount: 4000,
      concept: 'new deposit'
    )
    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :transfer,
      amount: 4000,
      concept: 'new transfer'
    )

    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :transfer,
      amount: 4000,
      concept: 'new transfer'
    )

    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :withdrawal,
      amount: 4000,
      concept: 'new withdrawal'
    )

    Operation.create(
      account_id: account_id,
      operationable_id: id,
      operationable_type: 'Card',
      kind: :withdrawal,
      amount: 4000,
      concept: 'new withdrawal'
    )
  end
end
