class ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token
  rescue_from ::ArgumentError, with: :argument_error
  rescue_from Apipie::ParamInvalid, with: :argument_error

  def account_params
    params.permit(:account_id)
  end

  def argument_error(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end
end
