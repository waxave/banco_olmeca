# frozen_string_literal: true

# Controller for handling deposit operations
class DepositController < ApplicationController
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

    result = DepositCommand.call(account: current_user, params: operation_params)

    if result.success?
      redirect_to new_deposit_path, notice: result.message
    else
      @operation = result.operation
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operationable_id)
  end
end
