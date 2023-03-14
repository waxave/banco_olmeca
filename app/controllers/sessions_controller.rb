class SessionsController < ApplicationController
  layout 'sessions', only: %i[new]
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
      redirect_to log_in_path, notice: validation.error
    end
  end

  def destroy
    session.delete(:account_id)
    @current_user = nil
    redirect_to root_path
  end

  def account_params
    params.require(:account).permit(:email, :password)
  end
end
