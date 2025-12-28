class Operation < ApplicationRecord
  ERRORS = {
    account_not_found: 'Account not found',
    withdrawal_error: 'The account don\'t have enough funds',
    transfer_error: 'The account don\'t have enough funds',
    invalid_operation: 'Invalid operation'
  }.freeze

  attr_accessor :operation_account

  belongs_to :account
  belongs_to :operationable, polymorphic: true

  enum :kind, %i[deposit withdrawal transfer], default: :deposit

  validates :concept, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :operationable, presence: false
  validates :kind, inclusion: { in: kinds.keys }

  after_validation :create_operation
  before_validation :set_operation_account

  scope :for_me, lambda { |account_id|
    account = Account.find_by_id(account_id)

    where(
      "account_id = ? OR
      (operationable_type = 'Account' AND operationable_id = ?) OR
      (operationable_type = 'Card' AND operationable_id IN (?))",
      account.id,
      account.id,
      account.cards.ids
    ).order(created_at: :desc)
  }

  class << self
    def new_transfer(params, current_account)
      transfer_params = params.merge(
        account_id: current_account,
        kind: :transfer
      )
      new(transfer_params)
    end

    def new_deposit(params, current_account)
      deposit_params = params.merge(
        account_id: current_account,
        operation_account: current_account,
        kind: :deposit
      )
      new(deposit_params)
    end

    def new_withdraw(params, current_account)
      withdraw_params = params.merge(
        account_id: current_account,
        operation_account: current_account,
        kind: :withdrawal
      )
      new(withdraw_params)
    end
  end

  private

  def create_operation
    unless operationable.present? && account.present?
      delete_error(:operationable)
      return add_error(:account_not_found)
    end

    send("create_#{kind}")
  end

  def create_deposit
    operationable.reload

    operationable.update_attribute(:balance, operationable.balance + amount)
  end

  def create_withdrawal
    operationable.reload

    return add_error(:withdrawal_error) if operationable.balance < amount

    operationable.update_attribute(:balance, operationable.balance - amount)
  end

  def create_transfer
    account.reload
    operationable.reload

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
    add_error(:invalid_operation) and return unless self.class.kinds.key?(kind.to_s)

    return if operationable.present?

    self.operationable =
      Card.find_by(id: operationable_id) ||
      Account.for_operation(operation_account) ||
      Card.for_operation(operation_account)
  end

  def broadcast_operation
    broadcast_prepend_to "operations_for_account_#{account.id}",
                         target: 'operations',
                         partial: 'operations/operation',
                         locals: { operation: self }

    broadcast_replace_to "balance_for_account_#{account.id}",
                         target: 'balance',
                         partial: 'application/balance',
                         locals: { balance: account.balance }

    if operationable.is_a?(Card) # rubocop:disable Style/GuardClause
      broadcast_replace_to "card_#{operationable.id}",
                           target: "card_#{operationable.id}",
                           partial: 'application/card',
                           locals: { card: operationable }

    end
  end
end
