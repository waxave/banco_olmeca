module AccountsHelper
  def current_user
    @current_user ||= Account.where(id: session[:user_id])
  end
end
