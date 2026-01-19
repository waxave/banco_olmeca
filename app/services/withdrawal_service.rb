# frozen_string_literal: true

# Service for handling withdrawal operations with idempotency
class WithdrawalService < BaseOperationService
  ERRORS = {
    insufficient_funds: 'Insufficient funds for withdrawal'
  }.freeze

  private

  def valid_operation?
    super && sufficient_funds?
  end

  def process_operation
    operationable.reload
    @original_balance = operationable.balance

    operationable.update!(balance: operationable.balance - amount)
  end

  def compensate_operation
    return unless @original_balance

    operationable.update!(balance: @original_balance)
  end

  def operation_kind
    :withdrawal
  end

  def sufficient_funds?
    operationable.balance >= amount
  end

  def handle_error(error)
    if !sufficient_funds?
      errors.add(:base, ERRORS[:insufficient_funds])
    else
      super
    end
  end
end
