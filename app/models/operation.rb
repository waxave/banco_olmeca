# == Schema Information
#
# Table name: operations
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )
#  concept            :string
#  idempotency_key    :string
#  kind               :integer
#  operationable_type :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint           not null
#  operationable_id   :bigint           not null
#
# Indexes
#
#  index_operations_on_account_id       (account_id)
#  index_operations_on_idempotency_key  (idempotency_key)
#  index_operations_on_operationable    (operationable_type,operationable_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#
class Operation < ApplicationRecord
  attr_accessor :operation_account

  belongs_to :account
  belongs_to :operationable, polymorphic: true

  enum :kind, %i[deposit withdrawal transfer], default: :deposit

  validates :concept, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :operationable, presence: false
  validates :kind, inclusion: { in: kinds.keys }

  # Add idempotency key field
  validates :idempotency_key, uniqueness: { allow_nil: true }

  scope :account_operation, ->(operation_id:, account_id:) { where(id: operation_id, account_id: account_id).first }
end
