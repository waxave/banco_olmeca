require "test_helper"

class ContactTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new contact without errors' do
    @contact = contacts(:account_one)

    assert_empty(@contact.errors)
  end

  test 'create a new contact without errors for Card' do
    @contact = contacts(:card_debit)

    assert_empty(@contact.errors)
    assert_equal(@contact.contactable_type, 'Card')
  end

  test 'create a new contact without errors for Account' do
    @contact = contacts(:account_one)

    assert_empty(@contact.errors)
    assert_equal(@contact.contactable_type, 'Account')
  end
end
