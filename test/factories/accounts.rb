# == Schema Information
#
# Table name: accounts
#
#  id              :bigint           not null, primary key
#  balance         :decimal(, )
#  clabe           :string(18)
#  email           :string
#  name            :string
#  password_digest :string
#  phone           :string(10)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :account do
    name { Faker::Name.name }
    phone { Faker::Number.number(digits: 10) }
    email { Faker::Internet.email }
    balance { 80_000 }
    password { Faker::Internet.password }
  end
end
