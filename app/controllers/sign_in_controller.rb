class SignInController < ApplicationController
  layout 'sign_in', only: %i[new]
  skip_before_action :logged_in?, only: %i[new create]

  def new
    @account = Account.new
  end

  def create
    validation = AccountValidator.call(account_params)

    if validation&.success?
      session[:account_id] = validation.payload.id
      redirect_to root_path
    else
      redirect_to new_sign_in_path, notice: validation.error
    end
  end

  def account_params
    params.require(:account).permit(:email, :password)
  end
end
