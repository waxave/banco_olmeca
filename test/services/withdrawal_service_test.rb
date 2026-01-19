require 'test_helper'

class WithdrawalServiceTest < ActiveSupport::TestCase
  def setup
    @account = create(:account) # Use factory default balance
    @card = create(:card, account: @account) # Use factory default balance
  end

  teardown do
    clear_enqueued_jobs
  end

  test 'successful withdrawal from account' do
    service = WithdrawalService.call(@account, 200, 'Test withdrawal')

    assert_equal ApplicationService::SUCCESS, service
    @account.reload
    assert_equal 79_800, @account.read_attribute(:balance) # Factory default - withdrawal

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test withdrawal', operation.concept
    assert_equal 'withdrawal', operation.kind
  end

  test 'successful withdrawal from card' do
    service = WithdrawalService.call(@account, 100, 'Card withdrawal', @card)

    assert_equal ApplicationService::SUCCESS, service
    @card.reload
    assert_equal 39_900, @card.balance # Factory default - withdrawal

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Card withdrawal', operation.concept
    assert_equal @card, operation.operationable
  end

  test 'handles withdrawal with insufficient funds from account' do
    service = WithdrawalService.call(@account, 150_000, 'Insufficient funds withdrawal')

    assert_equal ApplicationService::FAILURE, service
    @account.reload
    assert_equal 80_000, @account.read_attribute(:balance) # Factory default
  end

  test 'handles withdrawal with insufficient funds from card' do
    service = WithdrawalService.call(@account, 60_000, 'Insufficient funds withdrawal', @card)

    assert_equal ApplicationService::FAILURE, service
    @card.reload
    assert_equal 40_000, @card.balance # Factory default
  end
end
