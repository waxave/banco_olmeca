require 'test_helper'

class TransferServiceTest < ActiveSupport::TestCase
  def setup
    @source_account = create(:account, balance: 1000)
    @target_account = create(:account, balance: 500)
    @target_card = create(:card, account: @target_account, balance: 200)
  end

  test 'successful transfer between accounts' do
    service = TransferService.call(@source_account, 200, 'Test transfer', @target_account)

    assert_equal SUCCESS, service
    @source_account.reload
    @target_account.reload

    assert_equal 800, @source_account.balance
    assert_equal 700, @target_account.balance

    operation = Operation.last
    assert_equal 200, operation.amount
    assert_equal 'Test transfer', operation.concept
    assert_equal 'transfer', operation.kind
    assert_equal @target_account, operation.operationable
  end

  test 'successful transfer from account to card' do
    service = TransferService.call(@source_account, 100, 'Transfer to card', @target_card)

    assert_equal SUCCESS, service
    @source_account.reload
    @target_card.reload

    assert_equal 900, @source_account.balance
    assert_equal 300, @target_card.balance

    operation = Operation.last
    assert_equal 100, operation.amount
    assert_equal 'Transfer to card', operation.concept
    assert_equal @target_card, operation.operationable
  end

  test 'handles transfer with insufficient funds' do
    service = TransferService.call(@source_account, 1500, 'Insufficient funds transfer')

    assert_equal FAILURE, service
    @source_account.reload
    @target_account.reload

    assert_equal 1000, @source_account.balance
    assert_equal 500, @target_account.balance
    assert service.errors[:base].include?('Insufficient funds for transfer')
  end

  test 'handles transfer to same account' do
    service = TransferService.call(@source_account, 100, 'Same account transfer', @source_account)

    assert_equal FAILURE, service
    assert service.errors[:base].include?('Invalid transfer target')
  end

  test 'handles transfer with invalid target' do
    service = TransferService.call(@source_account, 100, 'Invalid target transfer', 'invalid')

    assert_equal FAILURE, service
    assert service.errors[:base].include?('Invalid transfer target')
  end
end
