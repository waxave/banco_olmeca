class CardAuthQuery < ApplicationQuery
  def initialize(number:, pin:)
    @number = number
    @pin = pin
  end

  def call
    Card.find_by(number: @number, pin: @pin, status: :enabled)
  end
end
