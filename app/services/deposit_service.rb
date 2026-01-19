# frozen_string_literal: true

# Service for handling deposit operations with idempotency
class DepositService < BaseOperationService
  private

  def process_operation
    operationable.reload
    @original_balance = operationable.read_attribute(:balance)

    operationable.update!(balance: operationable.read_attribute(:balance) + amount)
  end

  def compensate_operation
    return unless @original_balance

    operationable.update!(balance: @original_balance)
  end

  def operation_kind
    :deposit
  end
end
