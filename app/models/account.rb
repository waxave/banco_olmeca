# == Schema Information
#
# Table name: accounts
#
#  id              :bigint           not null, primary key
#  balance         :decimal(, )
#  clabe           :string(18)
#  email           :string
#  name            :string
#  password_digest :string
#  phone           :string(10)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Account < ApplicationRecord
  def self.for_operation(query)
    case query
    when Integer
      find_by(id: query)
    when String
      if query.match?(/\A\d+\z/)
        find_by(id: query.to_i) || find_by(email: query)
      else
        find_by(email: query)
      end
    end
  end
  # Associations
  has_many :cards, -> { order(:id) }
  has_many :operations
  has_many :contacts

  # Authentication
  has_secure_password

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone, length: { is: 10 }

  # Callbacks (for card creation)
  after_create :enqueue_card_creation_job

  # Helper methods
  def as_json(options = {})
    options[:except] ||= [:password_digest]
    super
  end

  private

  def enqueue_card_creation_job
    CardCreationJob.perform_later(id)
  end
end
