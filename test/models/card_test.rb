require "test_helper"

class CardTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new card without errors' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: 1000,
      account: @account
    )

    assert_empty(@card.errors)
  end

  test 'create a new credit card without errors' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 6640,
      balance: 9000,
      kind: :credit,
      account: @account
    )

    assert_empty(@card.errors)
  end

  test 'has errors when pin is invalid' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 21,
      balance: 9000,
      account: @account
    )

    assert_equal(@card.valid?, false)
    assert_includes(@card.errors[:pin], 'is the wrong length (should be 4 characters)')
  end

  test 'has only one default card' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @debit = Card.create(
      pin: 1234,
      balance: 9000,
      account: @account
    )

    @credit = Card.create(
      pin: 1234,
      balance: 9000,
      kind: :credit,
      account: @account
    )

    assert_equal(@debit.default, true)
    assert_equal(@credit.default, false)
  end
end
