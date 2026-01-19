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
    @original_balance = operationable.read_attribute(:balance)

    operationable.update!(balance: operationable.read_attribute(:balance) - amount)
  end

  def compensate_operation
    return unless @original_balance

    operationable.update!(balance: @original_balance)
  end

  def operation_kind
    :withdrawal
  end

  def sufficient_funds?
    operationable.read_attribute(:balance) >= amount
  rescue StandardError
    false
  end

  def handle_error(error)
    if sufficient_funds?
      super
    else
      errors.add(:base, ERRORS[:insufficient_funds])
    end
  end
end
