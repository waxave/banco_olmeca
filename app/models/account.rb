class Account < ApplicationRecord
  has_secure_password
  has_many :card
  has_many :contact
  has_many :operation

  alias cards card
  alias contacts contact
  alias operations operation

  attribute :balance, :decimal, default: 250_000
  validates :name, presence: true
  validates :phone, presence: true, length: { is: 10 }, uniqueness: true
  validates :password, presence: true
  validates :clabe, uniqueness: true
  validates :email, presence: true, uniqueness: true

  before_create :clabe_assignation
  after_create :create_default_cards

  class << self
    def for_operation(query)
      where(
        'id = ? OR email = ? OR clabe = ? OR phone = ?',
        query.to_i,
        query.to_s,
        query.to_s,
        query.to_s
      ).first
    end
  end

  def as_json(options = {})
    options[:except] ||= [:password_digest]
    super(options)
  end

  private

  def clabe_assignation
    self.clabe = clabe_generator
  end

  def clabe_generator(length = 4)
    a_ascii_char_code = 'A'.ord
    z_ascii_char_code = 'Z'.ord
    (0...length).map { rand(a_ascii_char_code..z_ascii_char_code).chr }.join
  end

  def create_default_cards
    Card.create(account_id: id, pin: 9999)
    Card.create(account_id: id, pin: 9999, kind: :credit)
    Card.create(account_id: id, pin: 9999, kind: :credit)
  end
end
