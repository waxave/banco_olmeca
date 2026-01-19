require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  include BCrypt
  include ActiveJob::TestHelper

  teardown do
    clear_enqueued_jobs
  end

  test 'create a new account without errors' do
    @account = accounts(:one)

    assert_empty(@account.errors)
  end

  test 'has errors when email has been taken' do
    @account_one = accounts(:one)
    @account_two = accounts(:email_repeated)

    assert_equal(@account_two.valid?, false)
    assert_includes(@account_two.errors[:email], 'ya está en uso')
  end

  test 'has errors when phone is not correct' do
    @account = accounts(:phone_incorrect)

    assert_equal(@account.valid?, false)
    assert_includes(@account.errors[:phone], 'debe tener 10 caracteres')
  end

  test 'enqueues card creation job after account creation' do
    assert_enqueued_jobs(1, only: CardCreationJob) do
      Account.create!(
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        password: 'password123',
        clabe: 'TEST'
      )
    end
  end
end
