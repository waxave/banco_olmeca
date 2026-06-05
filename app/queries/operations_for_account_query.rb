class OperationsForAccountQuery < ApplicationQuery
  def initialize(account_id:, limit: nil)
    @account_id = account_id
    @limit = limit
  end

  def call
    q = Operation.where(account_id: @account_id).order(created_at: :desc)
    @limit ? q.limit(@limit) : q
  end
end
