require 'test_helper'

class CardCreationJobTest < ActiveJob::TestCase
  test 'creates default cards for account' do
    account = create(:account)

    assert_difference('Card.count', 3) do
      CardCreationJob.perform_now(account.id)
    end

    # Verify the cards were created with correct attributes
    cards = Card.where(account_id: account.id)
    assert_equal 3, cards.count

    # Check card types
    debit_cards = cards.where(kind: :debit)
    credit_cards = cards.where(kind: :credit)

    assert_equal 1, debit_cards.count
    assert_equal 2, credit_cards.count

    # Verify all cards have the default PIN
    cards.each do |card|
      assert_equal 9999, card.pin
    end
  end

  test 'raises error when account not found' do
    assert_raises(ActiveRecord::RecordNotFound) do
      CardCreationJob.perform_now(99_999)
    end
  end
end
