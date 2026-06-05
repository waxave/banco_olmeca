# frozen_string_literal: true

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
FactoryBot.define do
  factory :card do
    association :account
    number { Faker::Finance.credit_card(:visa).delete('-') }
    expiration_month { Faker::Number.between(from: 1, to: 12) }
    expiration_year { Faker::Number.between(from: Time.current.year + 1, to: Time.current.year + 5) }
    cvv { Faker::Number.number(digits: 3) }
    pin { 9999 }
    balance { 40_000 }
    kind { 0 }
    status { 0 }
    default { false }
  end
end
