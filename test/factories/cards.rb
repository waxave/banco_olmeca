# frozen_string_literal: true

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
