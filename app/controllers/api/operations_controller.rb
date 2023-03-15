class Api::OperationsController < ApiController
  before_action :set_operation, only: %i[show update destroy]
  before_action :set_operations, only: %i[index]

  def index
    render json: @operations
  end

  def show
    render json: @operation
  end

  def create
    @operation = Operation.new(operation_params)

    if @operation.save
      render json: @operation, status: :created, location: @operation
    else
      render json: @operation.errors, status: :unprocessable_entity
    end
  end

  def update
    if @operation.update(operation_params)
      render json: @operation
    else
      render json: @operation.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @operation.destroy
  end

  private

  def set_operation
    @operation = Operation.find(params[:id])
  end

  def set_operations
    return @operations = Operation.all unless account_params[:account_id].present?

    @operations = Operation.for_me(account_params[:account_id])
  end

  def operation_params
    params.require(:operation).permit(:account_id, :concept, :amount, :kind, :operation_account)
  end
end
