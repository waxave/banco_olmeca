require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'log_in shows correctly' do
    get new_session_path

    assert_response :success
  end

  test 'log_in succesfully' do
    @account = FactoryBot.create(:account)

    post sessions_path, params: { account: { email: @account.email, password: @account.password } }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'log_in fails when has an invalid password or username' do
    @account = FactoryBot.create(:account)

    post sessions_path, params: { account: { email: @account.email, password: 'other_password' } }
    assert_response :redirect

    assert_redirected_to new_session_path
  end

  test 'log_out successfully' do
    @account = FactoryBot.create(:account)
    sign_in(@account)

    get root_path
    assert_response :success

    delete session_path(1)
    assert_redirected_to root_path
  end
end
