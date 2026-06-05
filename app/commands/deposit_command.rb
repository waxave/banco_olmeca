# frozen_string_literal: true

class DepositCommand
  include OperationSteps

  Result = Struct.new(:success?, :operation, :message)

  def self.call(account:, params: {})
    new(account, params).call
  end

  def initialize(account, params)
    @account = account
    @params = params
    @idempotency_key = params[:idempotency_key]
    @operation = nil
    @error_message = nil
  end

  def call
    existing = find_idempotent_operation
    return failure(existing, 'Operación idempotente ya registrada') if existing

    setup
    return failure(@operation, @error_message) if @operation.errors.any?

    persist!
  end

  private

  def setup
    assign_operation_data
    validate_amount
    validate_operationable_owner
  end

  def assign_operation_data
    @amount = amount_from_params
    @concept = concept_from_params
    @operationable = operationable_from_params
    @operation = build_operation(kind: :deposit, operationable: @operationable)
  end

  def validate_amount
    return if valid_amount?(@amount)

    @operation.errors.add(:amount, 'El monto debe ser mayor a 0')
  end

  def validate_operationable_owner
    return unless operationable_id_present?
    return if operationable_owner?(@operationable)

    @operation.errors.add(:operationable, 'Tarjeta de depósito no encontrada o no pertenece a la cuenta')
  end

  def persist!
    ActiveRecord::Base.transaction do
      update_balance!(@operationable, @amount)
      @operation.save!
    end
    Result.new(true, @operation, 'Depósito realizado exitosamente.')
  rescue StandardError
    failure(@operation, 'No se pudo realizar el depósito.')
  end

  def find_idempotent_operation
    return nil unless @idempotency_key

    Operation.find_by(idempotency_key: @idempotency_key)
  end

  def base_error_message(error)
    "Error: #{error.message}"
  end

  def failure(operation, message)
    Result.new(false, operation, message)
  end
end
