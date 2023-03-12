class Contact < ApplicationRecord
  belongs_to :account
  belongs_to :contactable, polymorphic: true

  validates :name, presence: true
end
