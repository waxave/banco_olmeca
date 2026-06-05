# == Schema Information
#
# Table name: cards
#
#  id               :bigint           not null, primary key
#  balance          :decimal(, )
#  cvv              :integer
#  default          :boolean
#  expiration_month :integer
#  expiration_year  :integer
#  kind             :integer
#  number           :string(16)
#  pin              :integer
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#
# Indexes
#
#  index_cards_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class CardTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new card without errors' do
    card = FactoryBot.build(:card, kind: :debit)
    assert card.valid?
    assert_empty(card.errors)
    assert_equal(card.kind, 'debit')
  end

  test 'create a new credit card without errors' do
    card = FactoryBot.build(:card, kind: :credit)
    assert card.valid?
    assert_empty(card.errors)
    assert_equal(card.kind, 'credit')
  end

  test 'has errors when pin is invalid' do
    card = FactoryBot.build(:card, pin: 123)
    assert_not card.valid?
    assert_includes(card.errors[:pin], 'debe tener 4 caracteres')
  end

  test 'has only one default card' do
    account = FactoryBot.create(:account)
    debit = FactoryBot.create(:card, account: account, kind: :debit, default: true)
    credit = FactoryBot.create(:card, account: account, kind: :credit, default: false)
    assert_equal(debit.default, true)
    assert_equal(credit.default, false)
  end
end
