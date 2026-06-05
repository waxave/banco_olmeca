# == Schema Information
#
# Table name: operations
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )
#  concept            :string
#  idempotency_key    :string
#  kind               :integer
#  operationable_type :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  operationable_id   :bigint           not null
#
# Indexes
#
#  index_operations_on_account_id       (account_id)
#  index_operations_on_idempotency_key  (idempotency_key)
#  index_operations_on_operationable    (operationable_type,operationable_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
# ... [schema comments unchanged] ...
require 'test_helper'

class OperationTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new deposit operation without errors' do
    account = FactoryBot.create(:account, balance: 5000)
    card = FactoryBot.create(:card, account: account, balance: 5000, kind: 0)
    amount = 100
    concept = 'new deposit'
    result = DepositCommand.call(account: account, params: { amount: amount, concept: concept, operationable: card })

    assert_equal true, result.success?
    assert_equal 5100, card.reload.balance
    assert_equal 'Depósito realizado exitosamente.', result.message
  end

  test 'create a new withdrawal operation without errors' do
    account = FactoryBot.create(:account, balance: 5000)
    card = FactoryBot.create(:card, account: account, balance: 5000, kind: 0)
    amount = 3000
    concept = 'new withdrawal'

    result = WithdrawalCommand.call(account: account, params: { amount: amount, concept: concept, operationable: card })

    assert_equal true, result.success?
    assert_equal 2000, card.reload.balance
    assert_equal 'Retiro realizado exitosamente.', result.message
  end

  test 'return an error when the account does not have enough funds to withdraw' do
    account = FactoryBot.create(:account, balance: 5000)
    card = FactoryBot.create(:card, account: account, balance: 5000, kind: 0)
    amount = 89_798
    concept = 'new withdrawal'
    original_balance = card[:balance]

    result = WithdrawalCommand.call(account: account, params: { amount: amount, concept: concept, operationable: card })

    assert_equal false, result.success?
    assert_equal original_balance, card.reload.balance
    assert_equal 'Fondos insuficientes para el retiro', result.message
  end

  test 'create a new transfer operation without errors' do
    account_one = FactoryBot.create(:account, balance: 80_000)
    account_two = FactoryBot.create(:account, balance: 150_000)
    amount = 3000
    concept = 'new transfer'
    original_source_balance = account_one[:balance]
    original_target_balance = account_two[:balance]

    result = TransferCommand.call(
      account: account_one,
      params: { amount: amount, concept: concept, operation_account: account_two.id }
    )

    assert_equal true, result.success?
    assert_equal original_source_balance - amount, account_one.reload[:balance]
    assert_equal original_target_balance + amount, account_two.reload[:balance]
  end

  test 'return an error when the account does not have enough funds to transfer (alternate)' do
    account_one = FactoryBot.create(:account, balance: 100)
    account_two = FactoryBot.create(:account, balance: 150_000)
    amount = 450_000
    concept = 'new transfer (alternate)'
    original_source_balance = account_one[:balance]
    original_target_balance = account_two[:balance]

    result = TransferCommand.call(
      account: account_one,
      params: { amount: amount, concept: concept, operation_account: account_two.id }
    )

    assert_equal false, result.success?
    assert_equal original_source_balance, account_one.reload[:balance]
    assert_equal original_target_balance, account_two.reload[:balance]
  end
end
