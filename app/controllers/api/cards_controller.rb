class Api::CardsController < ApiController
  before_action :set_card, only: %i[show update destroy]
  before_action :set_cards, only: %i[index]

  def index
    render json: @cards
  end

  def show
    render json: @card
  end

  def create
    @card = Card.new(card_params)

    if @card.save
      render json: @card, status: :created, location: @card
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  def update
    if @card.update(card_params)
      render json: @card
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy
  end

  private

  def set_card
    @card = Card.find(params[:id])
  end

  def set_cards
    return @cards = Card.all unless account_params[:account_id].present?

    @cards = Card.where(account_id: account_params[:account_id])
  end

  def card_params
    params.require(:card).permit(:number, :pin, :kind, :account_id)
  end
end
