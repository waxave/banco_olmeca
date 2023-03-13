class ApplicationController < ActionController::Base
  before_action :logged_in?

  def logged_in?
    session.clear
    return redirect_to(new_account_path) unless current_user.present?

    # session.clear
    # session.clear

    puts "current_user = #{current_user.present?}"

    current_user.present?
  end

  private

  def current_user
    puts "session[:account_id] = #{session[:account_id]}"
    return nil unless session[:account_id].present?

    @current_user ||= Account.find_by(id: session[:account_id])
  end
end
