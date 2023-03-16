FactoryBot.define do
  factory :account do
    name { Faker::Name.name }
    phone { Faker::Number.number(digits: 10) }
    email { Faker::Internet.email }
    balance { 80_000 }
    password { Faker::Internet.password }
  end
end
