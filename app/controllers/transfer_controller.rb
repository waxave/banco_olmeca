# frozen_string_literal: true

# Controller for handling transfer operations
class TransferController < ApplicationController
  def show
    @operation = Operation.account_operation(
      operation_id: params[:id],
      account_id: current_user.id
    )
  end

  def new
    @operation = Operation.new
  end

  def create
    # Call TransferCommand directly with extracted params
    result = TransferCommand.call(
      account: current_user,
      params: operation_params
    )

    @operation = result.operation

    if result.success?
      redirect_to new_transfer_path, notice: result.message
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operation_account)
  end
end
