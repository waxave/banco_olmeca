class TransferController < ApplicationController
  def new
    @operation = Operation.new
  end

  def create
    target_account = Account.for_operation(operation_params[:operation_account])

    unless target_account
      @operation = Operation.new(operation_params)
      @operation.errors.add(:base, 'Cuenta de destino no encontrada')
      render :new, status: :unprocessable_entity
      return
    end

    # Check for same account first
    if current_user.id == target_account.id
      @operation = Operation.new(operation_params)
      @operation.errors.add(:base, 'No se puede transferir a la misma cuenta')
      render :new, status: :unprocessable_entity
      return
    end

    result = TransferService.call(
      current_user,
      operation_params[:amount].to_d,
      operation_params[:concept],
      target_account
    )

    if result == ApplicationService::SUCCESS
      redirect_to new_transfer_path, notice: 'Transferencia realizada exitosamente.'
    else
      @operation = Operation.new(operation_params)
      @operation.errors.add(:base, 'Fondos insuficientes para la transferencia')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def operation_params
    params.require(:operation).permit(:concept, :amount, :operation_account)
  end
end
