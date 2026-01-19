require 'test_helper'

class DepositServiceTest < ActiveSupport::TestCase
  def setup
    @account = create(:account, balance: 1000)
    @card = create(:card, account: @account, balance: 500)
  end

  test 'successful deposit to account' do
    service = DepositService.call(@account, 200, 'Test deposit')

    assert_equal SUCCESS, service
    @account.reload
    assert_equal 1200, @account.balance

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test deposit', operation.concept
    assert_equal 'deposit', operation.kind
  end

  test 'successful deposit to card' do
    service = DepositService.call(@account, 100, 'Card deposit', @card)

    assert_equal SUCCESS, service
    @card.reload
    assert_equal 600, @card.balance

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Card deposit', operation.concept
    assert_equal @card, operation.operationable
  end

  test 'handles invalid deposit with zero amount' do
    service = DepositService.call(@account, 0, 'Invalid deposit')

    assert_equal FAILURE, service
    @account.reload
    assert_equal 1000, @account.balance
  end

  test 'handles deposit with nil account' do
    service = DepositService.call(nil, 100, 'Invalid deposit')

    assert_equal FAILURE, service
  end
end
