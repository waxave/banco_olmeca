require "test_helper"

class OperationTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new deposit operation without errors' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: 9000,
      account: @account
    )

    @operation = Operation.create(
      account: @account,
      operationable: @card,
      kind: :deposit,
      amount: 100,
      concept: 'new tranfer'
    )

    assert_empty(@operation.errors)
  end

  test 'create a new withdrawal operation without errors' do
    @starting_balance = 5000
    @withdrawal_quantity = 3000

    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: @starting_balance,
      account: @account
    )

    @operation = Operation.create(
      account: @account,
      operationable: @card,
      kind: :withdrawal,
      amount: @withdrawal_quantity,
      concept: 'new withdrawal'
    )

    assert_equal(@card.balance, @starting_balance - @withdrawal_quantity)
    assert_empty(@operation.errors)
  end

  test 'return an error when the account does not have enough funds to withdraw' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: 1000,
      account: @account
    )

    @operation = Operation.create(
      account: @account,
      operationable: @card,
      kind: :withdrawal,
      amount: 1500,
      concept: 'new withdrawal'
    )

    assert_equal(@operation.valid?, false)
    assert_includes(@operation.errors[:withdrawal_error], 'The account don\'t have enough funds')
  end

  test 'create a new transfer operation without errors' do
    @starting_balance_account = 15000
    @starting_balance_account_two = 5000
    @withdrawal_quantity = 3000

    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: @starting_balance_account,
      password: Password.create('meh')
    )

    @account_two = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'account_two@example.com',
      balance: @starting_balance_account_two,
      password: Password.create('meh')
    )

    @operation = Operation.create(
      account: @account,
      operationable: @account_two,
      kind: :transfer,
      amount: @withdrawal_quantity,
      concept: 'new withdrawal'
    )

    assert_empty(@operation.errors)
    assert_equal(@account.balance, @starting_balance_account - @withdrawal_quantity)
    assert_equal(@account_two.balance, @starting_balance_account_two + @withdrawal_quantity)
  end

  test 'return an error when the account does not have enough funds to transfer' do
    @starting_balance_account = 1000
    @starting_balance_account_two = 5000
    @withdrawal_quantity = 3000

    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: @starting_balance_account,
      password: Password.create('meh')
    )

    @account_two = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'account_two@example.com',
      balance: @starting_balance_account_two,
      password: Password.create('meh')
    )

    @operation = Operation.create(
      account: @account,
      operationable: @account_two,
      kind: :transfer,
      amount: @withdrawal_quantity,
      concept: 'new withdrawal'
    )

    assert_equal(@operation.valid?, false)
    assert_includes(@operation.errors[:transfer_error], 'The account don\'t have enough funds')
  end
end
