# frozen_string_literal: true

module OperationSteps
  def valid_amount?(amount)
    amount.present? && amount.to_d.positive?
  end

  def insufficient_funds?(operationable, amount)
    return false unless operationable&.balance

    operationable.balance < amount
  end

  def amount_from_params
    @params[:amount].to_d
  end

  def concept_from_params
    @params[:concept]
  end

  def operationable_from_params
    return @params[:operationable] if @params[:operationable]
    return Card.find_by(id: @params[:operationable_id]) if @params[:operationable_id].present?

    @account
  end

  def operationable_id_present?
    @params[:operationable_id].present?
  end

  def operationable_owner?(operationable)
    operationable && operationable.account_id == @account.id
  end

  def build_operation(kind:, operationable:)
    Operation.new(
      account: @account,
      amount: @amount,
      concept: @concept,
      kind: kind,
      operationable: operationable,
      operationable_id: operationable&.id,
      operationable_type: operationable&.class&.name,
      idempotency_key: @idempotency_key
    )
  end

  def record_operation(attrs)
    Operation.new(attrs)
  end

  def update_balance!(operationable, delta)
    operationable.reload
    operationable.update!(balance: operationable.balance + delta)
  end
end
