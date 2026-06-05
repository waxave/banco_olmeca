# frozen_string_literal: true

# Controller for handling withdrawal operations
class WithdrawalController < ApplicationController
  def show
    @operation = Operation.account_operation(
      operation_id: params[:id],
      account_id: current_user.id
    )
  end

  def new
    @operation = Operation.new
    @cards = current_user.cards
  end

  def create
    @cards = current_user.cards

    result = WithdrawalCommand.call(account: current_user, params: operation_params)
    @operation = result.operation

    if result.success?
      redirect_to new_withdrawal_path, notice: result.message
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operationable_id)
  end
end
