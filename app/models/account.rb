class Account < ApplicationRecord
  has_secure_password
  has_many :card
  has_many :contact
  has_many :operation

  alias cards card
  alias contacts contact
  alias operations operation
end
