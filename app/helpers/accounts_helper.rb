module AccountsHelper
  def current_user
    puts "current_user = #{session[:user_id]}"
    puts "session[:user_id] = #{session[:user_id]}"
    @current_user ||= Account.where(id: session[:user_id])
  end
end
