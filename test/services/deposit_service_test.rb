require 'test_helper'

class DepositServiceTest < ActiveSupport::TestCase
  def setup
    @account = create(:account) # Use factory default balance
    @card = create(:card, account: @account) # Use factory default balance
  end

  teardown do
    clear_enqueued_jobs
  end

  test 'successful deposit to account' do
    service = DepositService.call(@account, 200, 'Test deposit')

    assert_equal ApplicationService::SUCCESS, service
    @account.reload
    assert_equal 80_200, @account.read_attribute(:balance) # Factory default + deposit

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test deposit', operation.concept
    assert_equal 'deposit', operation.kind
  end

  test 'successful deposit to card' do
    service = DepositService.call(@account, 100, 'Card deposit', @card)

    assert_equal ApplicationService::SUCCESS, service
    @card.reload
    assert_equal 40_100, @card.balance # Factory default + deposit

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Card deposit', operation.concept
    assert_equal @card, operation.operationable
  end

  test 'handles invalid deposit with zero amount' do
    service = DepositService.call(@account, 0, 'Invalid deposit')

    assert_equal ApplicationService::FAILURE, service
    @account.reload
    assert_equal 80_000, @account.read_attribute(:balance) # Factory default
  end

  test 'handles deposit with nil account' do
    service = DepositService.call(nil, 100, 'Invalid deposit')

    assert_equal ApplicationService::FAILURE, service
  end
end
