class Operation < ApplicationRecord
  belongs_to :account
  belongs_to :operationable, polymorphic: true

  validates :concept, presence: true
  validates :amount, presence: true
  enum :kind, %i[deposit withdrawal transfer], default: :deposit
end
