class OperationsController < ApplicationController
  def show
    @operation = Operation.account_operation(
      operation_id: params[:id],
      account_id: current_user.id
    )

    respond_to do |format|
      format.turbo_stream
      format.html { render :show }
    end
  end
end
