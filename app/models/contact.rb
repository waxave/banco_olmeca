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
class Contact < ApplicationRecord
  belongs_to :account
  belongs_to :contactable, polymorphic: true

  validates :name, presence: true
end
