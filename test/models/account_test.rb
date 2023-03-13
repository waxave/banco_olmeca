require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new account without errors' do
    @account = accounts(:one)

    assert_empty(@account.errors)
  end

  test 'has errors when email has been taken' do
    @account_one = accounts(:one)
    @account_two = accounts(:email_repeated)

    assert_equal(@account_two.valid?, false)
    assert_includes(@account_two.errors[:email], 'has already been taken')
  end

  test 'has errors when phone is not correct' do
    @account = accounts(:phone_incorrect)

    assert_equal(@account.valid?, false)
    assert_includes(@account.errors[:phone], 'is the wrong length (should be 10 characters)')
  end
end
