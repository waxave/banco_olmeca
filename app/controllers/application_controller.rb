# frozen_string_literal: true

# ApplicationController is the base controller for all controllers in the application.
class ApplicationController < ActionController::Base
  before_action :logged_in?

  def logged_in?
    return redirect_to(new_session_path) unless current_user.present?

    current_user.present?
  end

  def logged_in!
    logged_in?
  end

  def current_user
    return nil unless session[:account_id].present?

    @current_user ||= Account.find_by(id: session[:account_id])
  end
end
