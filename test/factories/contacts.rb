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
FactoryBot.define do
  factory :contact do
    association :account
    name { Faker::Name.name }

    trait :for_account do
      association :contactable, factory: :account
      contactable_type { 'Account' }
    end

    trait :for_card do
      association :contactable, factory: :card
      contactable_type { 'Card' }
    end
  end
end
