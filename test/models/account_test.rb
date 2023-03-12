require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new account without errors' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    assert_empty(@account.errors)
  end

  test 'has errors when email has been taken' do
    Account.create!(
      name: 'account one',
      phone: '0123456789',
      email: 'email@error.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @account_two = Account.create(
      name: 'account two',
      phone: '0123456789',
      email: 'email@error.com',
      balance: 1000,
      password: Password.create('meh')
    )

    assert_equal(@account_two.valid?, false)
    assert_includes(@account_two.errors[:email], 'has already been taken')
  end

  test 'has errors when phone is not correct' do
    @account = Account.create(
      name: 'account with phone errors',
      phone: '01',
      email: 'phone@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    assert_equal(@account.valid?, false)
    assert_includes(@account.errors[:phone], 'is the wrong length (should be 10 characters)')
  end
end
