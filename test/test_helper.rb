ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  fixtures :all

  # simulates a session started
  def sign_in(account)
    open_session do |session|
      session.https!
      post log_in_path, params: { account: { email: account.email, password: 'secret' } }
      assert_response :redirect
      assert_redirected_to root_path
      session.https!(false)
    end
  end
end
