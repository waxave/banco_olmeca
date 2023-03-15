class Api::AccountsController < ApiController
  before_action :set_account, only: %i[show update destroy]

  def_param_group :account do
    param :account, Hash, desc: 'Param description for all methods' do
      param :name, String, desc: 'Account name', required: true
      param :phone, String, desc: 'Account phone', required: true
      param :email, String, desc: 'Account email', required: true
      param :password, String, desc: 'Password for login', required: true
      param :password_confirmation, String, desc: 'Password for login [confiramation]', required: true
    end
  end

  # GET /accounts
  api :GET, '/accounts', 'All existing accounts'
  def index
    @accounts = Account.all

    render json: @accounts
  end

  # GET /accounts/1
  api :GET, '/accounts/:id', 'Get an existing [Account]'
  param :id, :number, desc: 'id of the requested account'
  def show
    render json: @account
  end

  # POST /accounts
  api :POST, '/accounts', 'Creates a new [Account]'
  param_group :account
  def create
    @account = Account.new(account_params)

    if @account.save
      render json: @account, status: :created, location: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  api :PUT, '/accounts/:id', 'Update an existing [Account]'
  param_group :account
  def update
    if @account.update(account_params)
      render json: @account
    else
      render json: @account.errors, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  api :DELETE, '/accounts/:id', 'Delete and existing [Account]'
  param :id, :number, desc: 'id of the requested account'
  def destroy
    @account.destroy
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :phone, :email, :password, :password_confirmation)
  end
end
