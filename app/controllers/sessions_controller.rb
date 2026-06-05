# frozen_string_literal: true

# Controller for managing user sessions (login/logout)
class SessionsController < ApplicationController
  layout 'sessions', only: %i[new]
  skip_before_action :logged_in?, only: %i[new create]

  def new
    @account = Account.new
  end

  def create
    # Legacy AccountValidator removed; use Account model authentication
    account = Account.find_by(email: account_params[:email])

    if account&.authenticate(account_params[:password])
      session[:account_id] = account.id
      redirect_to root_path
    else
      redirect_to new_session_path, notice: 'Invalid email or password'
    end
  end

  def destroy
    session.clear
    @current_user = nil
    redirect_to root_path
  end

  def account_params
    params.require(:account).permit(:email, :password)
  end
end
