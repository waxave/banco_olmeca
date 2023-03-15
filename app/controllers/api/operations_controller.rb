class Api::OperationsController < ApiController
  before_action :set_operation, only: %i[show update destroy]
  before_action :set_operations, only: %i[index]

  def_param_group :operation do
    param :operation, Hash, desc: 'Operation params' do
      param :concept, String, desc: 'Operation concept', required: true
      param :amount, :number, desc: 'Operation amount', required: true
      param :kind, String, desc: 'Operation type [transfer, deposit, withdrawal]', required: true
      param :account_id, Integer, desc: 'Account related to this operation', required: true
      param :operationable_id, Integer, desc: 'Card id', required: false
      param :operation_account, String, desc: 'Card number or Account clabe, email, phone', required: false
    end
  end

  api :GET, '/operations', 'All existing operation'
  def index
    render json: @operations
  end

  api :GET, '/operations/:id', 'Get an existing Operation'
  param :id, :number, desc: 'id of the requested Operation'
  def show
    render json: @operation
  end

  api :POST, '/operations', 'Creates a new Operation'
  param_group :operation
  def create
    @operation = Operation.new(operation_params)

    if @operation.save
      render json: @operation, status: :created
    else
      render json: @operation.errors, status: :unprocessable_entity
    end
  end

  api :PUT, '/operations/:id', 'Update an existing Operation'
  param_group :operation
  def update
    if @operation.update(operation_params)
      render json: @operation
    else
      render json: @operation.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, '/operations/:id', 'Delete and existing Operation'
  param :id, :number, desc: 'id of the requested Operation'
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
    params.require(:operation).permit(:account_id, :concept, :amount, :kind, :operationable_id, :operation_account)
  end
end
