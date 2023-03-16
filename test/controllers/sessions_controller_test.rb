require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'log_in shows correctly' do
    get log_in_path

    assert_response :success
  end

  test 'log_in succesfully' do
    @user_one = accounts(:one)

    post log_in_path, params: { account: { email: @user_one.email, password: 'secret' } }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'log_in fails when has an invalid password or username' do
    @user_one = accounts(:one)

    post log_in_path, params: { account: { email: @user_one.email, password: 'other"_password' } }
    assert_response :redirect

    assert_redirected_to log_in_path
  end

  test 'log_out successfully' do
    @account = accounts(:one)
    sign_in(@account)

    get root_path
    assert_response :success

    get log_out_path
    assert_redirected_to root_path
  end
end
