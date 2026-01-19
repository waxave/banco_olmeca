require 'test_helper'

class CardTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new card without errors' do
    @card = cards(:debit)

    assert_empty(@card.errors)
    assert_equal(@card.kind, 'debit')
  end

  test 'create a new credit card without errors' do
    @card = cards(:credit)

    assert_empty(@card.errors)
    assert_equal(@card.kind, 'credit')
  end

  test 'has errors when pin is invalid' do
    @card = cards(:pin_invalid)

    assert_equal(@card.valid?, false)
    assert_includes(@card.errors[:pin], 'is the wrong length (should be 4 characters)')
  end

  test 'has only one default card' do
    @debit = cards(:debit_two)
    @credit = cards(:credit_two)

    assert_equal(@debit.default, true)
    assert_equal(@credit.default, false)
  end
end
