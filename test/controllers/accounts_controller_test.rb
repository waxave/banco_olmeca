require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test 'has two operations in dashboard' do
    @account_one = FactoryBot.create(:account)
    sign_in(@account_one)

    get accounts_path

    @current_user = assigns(:current_user)
    @operations = assigns(:operations)

    assert :success
    assert_equal @current_user.balance, 56_000
    assert_equal @operations.size, 18
  end

  test 'has zero operations in dashboard' do
    @account_two = FactoryBot.create(:account)
    @account_two.operations.destroy_all

    sign_in(@account_two)

    get accounts_path

    @current_user = assigns(:current_user)
    @operations = assigns(:operations)

    assert :success
    assert_equal @current_user.balance, 56_000
    assert_equal @operations.size, 0
  end

  test 'creates a new account succesfully' do
    @new_account = {
      account: {
        name: 'some person',
        email: 'some@person.com',
        phone: '0001234567',
        password: 'secret',
        password_confirmation: 'secret'
      }
    }

    post accounts_path, params: @new_account

    assert :success
  end

  test 'fails creating a new account when password is not the same' do
    @new_account = {
      account: {
        name: 'some person',
        email: 'some@person.com',
        phone: '0001234567',
        password: '123',
        password_confirmation: '456'
      }
    }

    post accounts_path, params: @new_account

    @account_response = assigns(:account)

    assert_equal(@account_response.valid?, false)
    assert_includes(@account_response.errors[:password_confirmation], 'doesn\'t match Password')
  end

  test 'fails creating a new account when phone is invalid' do
    @new_account = {
      account: {
        name: 'some person',
        email: 'one@example.com',
        phone: 'sss',
        password: '123',
        password_confirmation: '123'
      }
    }

    post accounts_path, params: @new_account

    @account_response = assigns(:account)

    assert_equal(@account_response.valid?, false)
    assert_includes(@account_response.errors[:phone], 'is the wrong length (should be 10 characters)')
  end
end
