# frozen_string_literal: true

# Base class for operation services with idempotency and compensation
class BaseOperationService < ApplicationService
  attr_reader :account, :amount, :concept, :operationable, :idempotency_key

  def initialize(account, amount, concept, operationable = nil, idempotency_key: nil)
    super()
    @account = account
    @amount = amount.to_d
    @concept = concept
    @operationable = operationable || account
    @idempotency_key = idempotency_key
  end

  def call
    return FAILURE unless valid_operation?
    return SUCCESS if operation_already_processed?

    ActiveRecord::Base.transaction do
      process_operation
      record_operation
    end

    SUCCESS
  rescue StandardError => e
    handle_error(e)
    FAILURE
  end

  private

  def valid_operation?
    account.present? && operationable.present? && amount.positive? && concept.present?
  end

  def operation_already_processed?
    return false unless idempotency_key

    Operation.exists?(idempotency_key:)
  end

  def process_operation
    raise NotImplementedError, 'Subclasses must implement process_operation'
  end

  def record_operation
    Operation.create!(
      account:,
      operationable:,
      amount:,
      concept:,
      kind: operation_kind,
      idempotency_key:
    )
  end

  def operation_kind
    raise NotImplementedError, 'Subclasses must implement operation_kind'
  end

  def handle_error(error)
    Rails.logger.error "Operation failed: #{error.message}"
    compensate_operation if respond_to?(:compensate_operation, true)
  end
end
