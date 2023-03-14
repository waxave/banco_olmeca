class TransferController < ApplicationController
  def new
    @operation = Operation.new
  end

  def create
    @operation = Operation.new_transfer(operation_params, current_user.id)

    if @operation.save
      redirect_to new_transfer_path, notice: 'Transfer was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operation_account)
  end
end
