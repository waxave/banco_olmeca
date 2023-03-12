class Account < ApplicationRecord
  has_secure_password
  has_many :card
  has_many :contact
end
