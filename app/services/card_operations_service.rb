# frozen_string_literal: true

# Service for creating default card operations
class CardOperationsService < ApplicationService
  OPERATIONS = [
    { kind: :deposit, amount: 4000, concept: 'new deposit' },
    { kind: :deposit, amount: 4000, concept: 'new deposit' },
    { kind: :transfer, amount: 4000, concept: 'new transfer' },
    { kind: :transfer, amount: 4000, concept: 'new transfer' },
    { kind: :withdrawal, amount: 4000, concept: 'new withdrawal' },
    { kind: :withdrawal, amount: 4000, concept: 'new withdrawal' }
  ].freeze

  def initialize(card)
    @card = card
  end

  def call
    OPERATIONS.each { |operation| create_operation(operation) }
    SUCCESS
  rescue StandardError => e
    Rails.logger.error "Failed to create default card operations: #{e.message}"
    FAILURE
  end

  private

  def create_operation(operation_params)
    Operation.create!(
      account_id: @card.account_id,
      operationable_id: @card.id,
      operationable_type: 'Card',
      kind: operation_params[:kind],
      amount: operation_params[:amount],
      concept: operation_params[:concept]
    )
  end
end
