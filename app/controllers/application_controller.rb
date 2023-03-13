class ApplicationController < ActionController::Base
  before_action :logged_in?

  def logged_in?
    # session.clear
    return redirect_to(new_sign_in_path) unless current_user.present?

    current_user.present?
  end

  private

  def current_user
    return nil unless session[:account_id].present?

    @current_user ||= Account.find_by(id: session[:account_id])
  end
end
