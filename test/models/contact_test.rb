require "test_helper"

class ContactTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new contact without errors' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: 9000,
      account: @account
    )

    @contact = Contact.create(
      name: "new contact for: #{@card.number}",
      account: @account,
      contactable: @card
    )

    assert_empty(@contact.errors)
  end

  test 'create a new contact without errors for Card' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @card = Card.create(
      pin: 8901,
      balance: 9000,
      account: @account
    )

    @contact = Contact.create(
      name: "new contact for: #{@card.number}",
      account: @account,
      contactable: @card
    )

    assert_empty(@contact.errors)
    assert_equal(@contact.contactable_type, 'Card')
  end

  test 'create a new contact without errors for Account' do
    @account = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'without@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @account_two = Account.create(
      name: 'account without errors',
      phone: '0123456789',
      email: 'account_two_without_errors@errors.com',
      balance: 1000,
      password: Password.create('meh')
    )

    @contact = Contact.create(
      name: "new contact for: #{@account_two.clabe}",
      account: @account,
      contactable: @account_two
    )

    assert_empty(@contact.errors)
    assert_equal(@contact.contactable_type, 'Account')
  end
end
