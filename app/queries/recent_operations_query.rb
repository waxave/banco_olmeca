# frozen_string_literal: true

# Query object for fetching recent operations
class RecentOperationsQuery < ApplicationQuery
  def initialize(account, limit = 10)
    @account = account
    @limit = limit
  end

  def call
    Operation.where(account: @account).order(created_at: :desc).limit(@limit)
  end
end
