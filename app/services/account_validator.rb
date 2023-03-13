class AccountValidator < ApplicationService
  attr_reader :email, :password

  def initialize(params)
    @email = params[:email]
    @password = params[:password]
  end

  def call
    account = Account.find_by_email(email)
    if account&.authenticate(password)
      OpenStruct.new({ success?: true, payload: account })
    else
      OpenStruct.new({ success?: false, error: 'Account does not exist' })
    end
  end
end
