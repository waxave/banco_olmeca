class DepositController < ApplicationController
  def new
    @operation = Operation.new
  end

  def create
    @operation = Operation.new_deposit(operation_params, current_user.id)

    if @operation.save
      redirect_to new_deposit_path, notice: 'Deposit was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount)
  end
end
