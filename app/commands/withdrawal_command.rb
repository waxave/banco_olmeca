# frozen_string_literal: true

class WithdrawalCommand
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
    validate_funds
  end

  def assign_operation_data
    @amount = amount_from_params
    @concept = concept_from_params
    @operationable = operationable_from_params
    @operation = build_operation(kind: :withdrawal, operationable: @operationable)
  end

  def validate_amount
    return if valid_amount?(@amount)

    @operation.errors.add(:base, 'El monto debe ser mayor a 0')
  end

  def validate_operationable_owner
    return unless operationable_id_present?
    return if operationable_owner?(@operationable)

    @operation.errors.add(:base, 'Tarjeta de retiro no encontrada o no pertenece a la cuenta')
  end

  def validate_funds
    return unless insufficient_funds?(@operationable, @amount)

    @operation.errors.add(:amount, 'Fondos insuficientes para el retiro')
  end

  def persist!
    ActiveRecord::Base.transaction do
      update_balance!(@operationable, -@amount)
      @operation.save!
    end
    Result.new(true, @operation, 'Retiro realizado exitosamente.')
  rescue StandardError
    failure(@operation, 'No se pudo realizar el retiro.')
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
