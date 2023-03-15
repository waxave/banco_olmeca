class Api::CardsController < ApiController
  before_action :set_card, only: %i[show update destroy]
  before_action :set_cards, only: %i[index]

  def_param_group :card do
    param :card, Hash, desc: 'Card params' do
      param :number, String, desc: 'Card number', required: true
      param :pin, String, desc: 'Card pin', required: true
      param :kind, String, desc: 'Card type', required: true
      param :account_id, String, desc: 'Account related to this card', required: true
    end
  end

  api :GET, '/cards', 'All existing cards'
  def index
    render json: @cards
  end

  api :GET, '/cards/:id', 'Get an existing Card'
  param :id, :number, desc: 'id of the requested Card'
  def show
    render json: @card
  end

  api :POST, '/cards', 'Creates a new Card'
  param_group :card
  def create
    @card = Card.new(card_params)

    if @card.save
      render json: @card, status: :created, location: @card
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end
  api :PUT, '/cards/:id', 'Update an existing Card'
  param_group :card
  def update
    if @card.update(card_params)
      render json: @card
    else
      render json: @card.errors, status: :unprocessable_entity
    end
  end

  api :DELETE, '/cards/:id', 'Delete and existing Card'
  param :id, :number, desc: 'id of the requested Card'
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
