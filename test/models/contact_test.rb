# == Schema Information
#
# Table name: contacts
#
#  id               :bigint           not null, primary key
#  contactable_type :string           not null
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_id       :bigint           not null
#  contactable_id   :bigint           not null
#
# Indexes
#
#  index_contacts_on_account_id   (account_id)
#  index_contacts_on_contactable  (contactable_type,contactable_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  include BCrypt

  test 'create a new contact without errors' do
    account = FactoryBot.create(:account)
    contact = FactoryBot.build(:contact, account: account, contactable: account)
    assert contact.valid?
    assert_empty(contact.errors)
  end

  test 'create a new contact without errors for Card' do
    account = FactoryBot.create(:account)
    card = FactoryBot.create(:card, account: account)
    contact = FactoryBot.build(:contact, :for_card, account: account, contactable: card)
    assert contact.valid?
    assert_empty(contact.errors)
    assert_equal(contact.contactable_type, 'Card')
  end

  test 'create a new contact without errors for Account' do
    account = FactoryBot.create(:account)
    contact = FactoryBot.build(:contact, account: account, contactable: account)
    assert contact.valid?
    assert_empty(contact.errors)
    assert_equal(contact.contactable_type, 'Account')
  end
end
