class CardsForAccountQuery < ApplicationQuery
  def initialize(account_id:, status: nil, default: nil)
    @account_id = account_id
    @status = status
    @default = default
  end

  def call
    q = Card.where(account_id: @account_id)
    q = q.where(status: @status) if @status
    q = q.where(default: @default) unless @default.nil?
    q
  end
end
