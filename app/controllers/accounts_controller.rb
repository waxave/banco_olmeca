class AccountsController < ApplicationController
  layout 'sessions', only: %i[new create]
  skip_before_action :logged_in?, only: %i[new create]

  def index
    @operations = Operation.for_me(current_user.id)
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "@operations = #{current_user.operations.size}"
    puts "@operations = #{@operations.size}"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    puts "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to new_account_path, notice: 'Account created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:name, :clabe, :phone, :email, :balance, :password, :password_confirmation)
  end
end
