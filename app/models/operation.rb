class Operation < ApplicationRecord
  belongs_to :account
  belongs_to :operationable, polymorphic: true

  validates :concept, presence: true
  validates :amount, presence: true
  enum :kind, %i[deposit withdrawal transfer], default: :deposit

  after_validation :create_operation

  private

  ERRORS = {
    account_not_found: 'Account not found',
    withdrawal_error: 'The account don\'t have enough funds',
    transfer_error: 'The account don\'t have enough funds'
  }.freeze

  def create_operation
    unless operationable.present? && account.present?
      return errors.add(:account_not_found, ERRORS[:account_not_found])
    end

    send("create_#{kind}")
  end

  def create_deposit
    operationable.balance += amount
  end

  def create_withdrawal
    return errors.add(:withdrawal_error, ERRORS[:withdrawal_error]) if operationable.balance < amount

    operationable.balance -= amount
  end

  def create_transfer
    return errors.add(:transfer_error, ERRORS[:transfer_error]) if account.balance < amount

    account.balance -= amount
    operationable.balance += amount
  end
end
