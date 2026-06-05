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
require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  include BCrypt
  include ActiveJob::TestHelper

  teardown do
    clear_enqueued_jobs
  end

  test 'create a new account without errors' do
    account = FactoryBot.build(:account)
    assert account.valid?
    assert_empty(account.errors)
  end

  test 'has errors when email has been taken' do
    email = 'duplicate@example.com'
    FactoryBot.create(:account, email: email)
    account_two = FactoryBot.build(:account, email: email)

    assert_not account_two.valid?
    assert_includes(account_two.errors[:email], 'ya está en uso')
  end

  test 'has errors when phone is not correct' do
    account = FactoryBot.build(:account, phone: '1234')

    assert_not account.valid?
    assert_includes(account.errors[:phone], 'debe tener 10 caracteres')
  end

  test 'enqueues card creation job after account creation' do
    assert_enqueued_jobs(1, only: CardCreationJob) do
      FactoryBot.create(:account,
                        name: 'Test User',
                        email: 'test@example.com',
                        phone: '1234567890',
                        password: 'password123',
                        clabe: 'TEST')
    end
  end
end
