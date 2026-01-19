# frozen_string_literal: true

# Service for handling transfer operations with idempotency
class TransferService < BaseOperationService
  ERRORS = {
    insufficient_funds: 'Insufficient funds for transfer',
    invalid_target: 'Invalid transfer target',
    same_account: 'No se puede transferir a la misma cuenta'
  }.freeze

  attr_reader :target_account

  def initialize(account, amount, concept, target_account)
    super(account, amount, concept, target_account)
    @target_account = target_account
  end

  private

  def valid_operation?
    super && valid_transfer?
  end

    def valid_transfer?
        return false unless target_account.is_a?(Account)
        return false if account == target_account

        sufficient_funds?
    end

  def process_operation
    load_accounts
    save_original_balances
    update_balances
  end

  def load_accounts
    account.reload
    target_account.reload
  end

  def save_original_balances
    @original_source_balance = account.balance
    @original_target_balance = target_account.balance
  end

  def update_balances
    account.update!(balance: account.balance - amount)
    target_account.update!(balance: target_account.balance + amount)
  end

  def compensate_operation
    return unless @original_source_balance && @original_target_balance

    account.update!(balance: @original_source_balance)
    target_account.update!(balance: @original_target_balance)
  end

  def operation_kind
    :transfer
  end

  def sufficient_funds?
    account.balance >= amount
  end

  def handle_error(error)
    if !sufficient_funds?
      errors.add(:base, ERRORS[:insufficient_funds])
    elsif account == target_account
      errors.add(:base, ERRORS[:same_account])
    elsif !target_account.is_a?(Account)
      errors.add(:base, ERRORS[:invalid_target])
    else
      super
    end
  end
end
