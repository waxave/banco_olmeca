require 'test_helper'

class WithdrawalServiceTest < ActiveSupport::TestCase
  def setup
    @account = create(:account, balance: 1000)
    @card = create(:card, account: @account, balance: 500)
  end

  test 'successful withdrawal from account' do
    service = WithdrawalService.call(@account, 200, 'Test withdrawal')

    assert_equal SUCCESS, service
    @account.reload
    assert_equal 800, @account.balance

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test withdrawal', operation.concept
    assert_equal 'withdrawal', operation.kind
  end

  test 'successful withdrawal from card' do
    service = WithdrawalService.call(@account, 100, 'Card withdrawal', @card)

    assert_equal SUCCESS, service
    @card.reload
    assert_equal 400, @card.balance

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Card withdrawal', operation.concept
    assert_equal @card, operation.operationable
  end

  test 'handles withdrawal with insufficient funds from account' do
    service = WithdrawalService.call(@account, 1500, 'Insufficient funds withdrawal')

    assert_equal FAILURE, service
    @account.reload
    assert_equal 1000, @account.balance
    assert service.errors[:base].include?('Insufficient funds for withdrawal')
  end

  test 'handles withdrawal with insufficient funds from card' do
    service = WithdrawalService.call(@account, 600, 'Insufficient funds withdrawal', @card)

    assert_equal FAILURE, service
    @card.reload
    assert_equal 500, @card.balance
    assert service.errors[:base].include?('Insufficient funds for withdrawal')
  end
end
