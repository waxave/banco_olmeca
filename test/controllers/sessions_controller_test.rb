require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'log_in shows correctly' do
    get log_in_path

    assert_response :success
  end

  test 'log_in succesfully' do
    @account = FactoryBot.create(:account)

    post log_in_path, params: { account: { email: @account.email, password: @account.password } }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test 'log_in fails when has an invalid password or username' do
    @account = FactoryBot.create(:account)

    post log_in_path, params: { account: { email: @account.email, password: 'other_password' } }
    assert_response :redirect

    assert_redirected_to log_in_path
  end

  test 'log_out successfully' do
    @account = FactoryBot.create(:account)
    sign_in(@account)

    get root_path
    assert_response :success

    get log_out_path
    assert_redirected_to root_path
  end
end
