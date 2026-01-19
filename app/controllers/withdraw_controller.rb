class WithdrawController < ApplicationController
  def new
    @operation = Operation.new
    @cards = current_user.cards
  end

  def create
    @cards = current_user.cards

    # Find the target card if specified
    target_card = if operation_params[:operationable_id].present?
                    Card.find_by(id: operation_params[:operationable_id])
                  else
                    current_user
                  end

    result = WithdrawalService.call(
      current_user,
      operation_params[:amount].to_d,
      operation_params[:concept],
      target_card
    )

    if result == ApplicationService::SUCCESS
      redirect_to new_withdraw_path, notice: 'Retiro realizado exitosamente.'
    else
      @operation = Operation.new(operation_params)
      @operation.errors.add(:base, 'Fondos insuficientes para el retiro')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operationable_id)
  end
end
