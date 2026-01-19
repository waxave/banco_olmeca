require 'test_helper'

class BaseOperationServiceTest < ActiveSupport::TestCase
  def setup
    @account = create(:account, balance: 1000)
    @card = create(:card, account: @account, balance: 500)
  end

  test 'handles idempotency correctly' do
    idempotency_key = 'test-key-123'

    service = DepositService.new(@account, 100, 'Test deposit', @card, idempotency_key:)

    assert_equal SUCCESS, service.call
    assert_equal 1, Operation.where(idempotency_key:).count

    # Second call should not create new operation
    assert_equal SUCCESS, service.call
    assert_equal 1, Operation.where(idempotency_key:).count
  end
end
