class ApiController < ActionController::Base
  def account_params
    params.permit(:account_id)
  end
end
