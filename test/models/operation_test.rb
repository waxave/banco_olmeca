require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new deposit operation without errors' do
    @operation = operations(:success)

    assert_empty(@operation.errors)
  end

  test 'create a new withdrawal operation without errors' do
    @account = accounts(:one)
    @card = cards(:debit)
    @withdrawal_quantity = 3000
    @starting_balance = @card.balance

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
    @account = accounts(:one)
    @card = cards(:debit)

    @operation = Operation.create(
      account: @account,
      operationable: @card,
      kind: :withdrawal,
      amount: 89_798,
      concept: 'new withdrawal'
    )

    assert_equal(@operation.valid?, false)
    assert_includes(@operation.errors[:withdrawal_error], 'The account don\'t have enough funds')
  end

  test 'create a new transfer operation without errors' do
    @account_one = accounts(:one)
    @account_two = accounts(:two)
    @starting_balance_account_one = @account_one.balance
    @starting_balance_account_two = @account_two.balance
    @withdrawal_quantity = 3000

    @operation = Operation.create(
      account: @account_one,
      operationable: @account_two,
      kind: :transfer,
      amount: @withdrawal_quantity,
      concept: 'new withdrawal'
    )

    assert_empty(@operation.errors)
    assert_equal(@account_one.balance, @starting_balance_account_one - @withdrawal_quantity)
    assert_equal(@account_two.balance, @starting_balance_account_two + @withdrawal_quantity)
  end

  test 'return an error when the account does not have enough funds to transfer' do
    @account_one = accounts(:one)
    @account_two = accounts(:two)
    @starting_balance_account_one = @account_one.balance
    @starting_balance_account_two = @account_two.balance
    @transfer_quantity = 450_000

    @operation = Operation.create(
      account: @account_one,
      operationable: @account_two,
      kind: :transfer,
      amount: @transfer_quantity,
      concept: 'new withdrawal'
    )

    assert_equal(@operation.valid?, false)
    assert_includes(@operation.errors[:transfer_error], 'The account don\'t have enough funds')
  end
end
