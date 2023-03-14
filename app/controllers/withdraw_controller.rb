class WithdrawController < ApplicationController
  def new
    @operation = Operation.new
    @cards = current_user.cards
  end

  def create
    @operation = Operation.new_withdraw(operation_params, current_user.id)
    @cards = current_user.cards

    if @operation.save
      redirect_to new_withdraw_path, notice: 'Withdrawal was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operationable_id)
  end
end
