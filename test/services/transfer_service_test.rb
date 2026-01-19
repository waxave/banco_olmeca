require 'test_helper'

class TransferServiceTest < ActiveSupport::TestCase
  def setup
    @source_account = create(:account) # Use factory default balance
    @target_account = create(:account) # Use factory default balance
    @target_card = create(:card, account: @target_account) # Use factory default balance
  end

  teardown do
    clear_enqueued_jobs
  end

  test 'successful transfer between accounts' do
    service = TransferService.call(@source_account, 200, 'Test transfer', @target_account)

    assert_equal ApplicationService::SUCCESS, service
    @source_account.reload
    @target_account.reload

    assert_equal 79_800, @source_account.read_attribute(:balance) # Factory default - transfer
    assert_equal 80_200, @target_account.read_attribute(:balance) # Factory default + transfer

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test transfer', operation.concept
    assert_equal 'transfer', operation.kind
    assert_equal @target_account, operation.operationable
  end

  test 'successful transfer from account to card' do
    service = TransferService.call(@source_account, 100, 'Transfer to card', @target_card)

    assert_equal ApplicationService::SUCCESS, service
    @source_account.reload
    @target_card.reload

    assert_equal 79_900, @source_account.read_attribute(:balance) # Factory default - transfer
    assert_equal 40_100, @target_card.read_attribute(:balance) # Factory default + transfer

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Transfer to card', operation.concept
    assert_equal @target_card, operation.operationable
  end

  test 'handles transfer with insufficient funds' do
    service = TransferService.call(@source_account, 150_000, 'Insufficient funds transfer', @target_account)

    assert_equal ApplicationService::FAILURE, service
    @source_account.reload
    @target_account.reload

    assert_equal 80_000, @source_account.read_attribute(:balance) # Factory default
    assert_equal 80_000, @target_account.read_attribute(:balance) # Factory default
  end

  test 'handles transfer to same account' do
    service = TransferService.call(@source_account, 100, 'Same account transfer', @source_account)

    assert_equal ApplicationService::FAILURE, service
  end

  test 'handles transfer with invalid target' do
    service = TransferService.call(@source_account, 100, 'Invalid target transfer', 'invalid')

    assert_equal ApplicationService::FAILURE, service
  end
end
