# frozen_string_literal: true

class TransferCommand
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
    return Result.new(true, existing, 'Operación idempotente ya registrada') if existing

    setup
    return failure(@operation, @error_message) if @operation.errors.any?

    persist!
  end

  private

  def setup
    assign_operation_data
    validate_target_account
    validate_not_same_account
    validate_amount
    validate_funds
  end

  def assign_operation_data
    @amount = amount_from_params
    @concept = concept_from_params
    @target_account = Account.for_operation(@params[:operation_account])
    @operation = build_operation(kind: :transfer, operationable: @target_account)
  end

  def validate_target_account
    return if @target_account

    @operation.errors.add(:base, 'Cuenta de destino no encontrada')
  end

  def validate_not_same_account
    return if @account.id != @target_account&.id

    @operation.errors.add(:base, 'No se puede transferir a la misma cuenta')
  end

  def validate_amount
    return if valid_amount?(@amount)

    @operation.errors.add(:amount, 'El monto debe ser mayor a 0')
  end

  def validate_funds
    return unless insufficient_funds?(@account, @amount)

    @operation.errors.add(:amount, 'Fondos insuficientes para la transferencia')
  end

  def persist!
    ActiveRecord::Base.transaction do
      # Debito para cuenta origen
      update_balance!(@account, -@amount)
      # Salida
      operation_out = build_operation(kind: :transfer, operationable: @target_account)
      operation_out.idempotency_key = "#{@idempotency_key}-out" if @idempotency_key
      operation_out.save!

      # Entrada
      update_balance!(@target_account, @amount)
      operation_in = Operation.new(
        account: @target_account,
        amount: @amount,
        concept: @concept,
        kind: :transfer,
        operationable: @account,
        idempotency_key: @idempotency_key ? "#{@idempotency_key}-in" : nil
      )
      operation_in.save!

      @operation = operation_out
    end
    Result.new(true, @operation, 'Transferencia realizada exitosamente.')
  rescue StandardError
    failure(@operation, 'Error en la transferencia.')
  end

  def find_idempotent_operation
    return nil unless @idempotency_key

    # Buscar solo la operación de salida (para idempotencia)
    Operation.find_by(idempotency_key: @idempotency_key ? "#{@idempotency_key}-out" : nil)
  end

  def base_error_message(error)
    "Error: #{error.message}"
  end

  def failure(operation, message)
    Result.new(false, operation, message)
  end
end
