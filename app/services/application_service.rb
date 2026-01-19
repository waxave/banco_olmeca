# frozen_string_literal: true

class ApplicationService
  RETURNS = [
    SUCCESS = :success,
    FAILURE = :failure,
    PARTIAL_SUCCESS = :partial_success
  ].freeze

  def self.call(*args, &block)
    new(*args, &block).call
  end
end
