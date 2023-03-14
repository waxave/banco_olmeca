class Operation < ApplicationRecord
  attr_accessor :operation_account

  belongs_to :account
  belongs_to :operationable, polymorphic: true

  validates :concept, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :operationable, presence: false
  enum :kind, %i[deposit withdrawal transfer], default: :deposit

  after_validation :create_operation
  before_validation :set_operation_account

  scope :for_me, ->(account_id) do
    account = Account.find_by_id(account_id)

    where(
      "account_id = ? OR
      (operationable_type = 'Account' AND operationable_id = ?) OR
      (operationable_type = 'Card' AND operationable_id IN (?))",
      account.id,
      account.id,
      account.cards.ids
    ).order(created_at: :desc)
  end

  class << self
    def new_transfer(transfer_params, current_account)
      transfer_params = transfer_params.merge(
        account_id: current_account,
        kind: :transfer
      )
      new(transfer_params)
    end

    def new_deposit(transfer_params, current_account)
      transfer_params = transfer_params.merge(
        account_id: current_account,
        operation_account: current_account,
        kind: :deposit
      )
      new(transfer_params)
    end

    def new_withdraw(transfer_params, current_account)
      transfer_params = transfer_params.merge(
        account_id: current_account,
        operation_account: current_account,
        kind: :withdrawal
      )
      new(transfer_params)
    end
  end

  private

  ERRORS = {
    account_not_found: 'Account not found',
    withdrawal_error: 'The account don\'t have enough funds',
    transfer_error: 'The account don\'t have enough funds'
  }.freeze

  def create_operation
    unless operationable.present? && account.present?
      delete_error(:operationable)
      return add_error(:account_not_found)
    end

    send("create_#{kind}")
  end

  def create_deposit
    operationable.update_attribute(:balance, operationable.balance + amount)
  end

  def create_withdrawal
    return add_error(:withdrawal_error) if operationable.balance < amount

    operationable.update_attribute(:balance, operationable.balance - amount)
  end

  def create_transfer
    return add_error(:transfer_error) if account.balance < amount

    account.update_attribute(:balance, account.balance - amount)
    operationable.update_attribute(:balance, operationable.balance + amount)
  end

  def add_error(error)
    errors.add(error, ERRORS[error])
  end

  def delete_error(error)
    errors.delete(error)
  end

  def set_operation_account
    return self.operationable = Card.find(operationable_id) if operationable_id.present?

    return unless operationable.present? || operation_account.present?

    account = Account.for_operation(operation_account).first
    card = Card.for_operation(operation_account).first

    self.operationable = account.present? ? account : card
  end
end
