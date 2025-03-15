class TicketsController < ApplicationController
  include JwtAuthentication
  include RoleAuthorization
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action :set_ticket, only: [:show, :update, :destroy]
  before_action :authorize_event_organizer!, only: [:create, :update, :destroy]
  before_action :authorize_ticket_access!, only: [:update, :destroy]

  def index
    @event = Event.find(params[:event_id])
    @tickets = @event.tickets
    render json: @tickets
  end

  def show
    render json: @ticket
  end

  def create
    @event = Event.find(params[:event_id])
    
    # Ensure the current user owns the event
    unless @event.event_organizer_id == current_user.event_organizer.id
      return render json: { error: 'Unauthorized to create tickets for this event' }, status: :forbidden
    end

    @ticket = @event.tickets.build(ticket_params)

    if @ticket.save
      render json: @ticket, status: :created
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @ticket.bookings.exists?
      render json: { error: 'Cannot delete ticket with existing bookings' }, status: :unprocessable_entity
    else
      @ticket.destroy
      head :no_content
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Ticket not found' }, status: :not_found
  end

  def ticket_params
    params.require(:ticket).permit(:ticket_type, :price, :quantity)
  end

  def authorize_ticket_access!
    unless @ticket.event.event_organizer_id == current_user.event_organizer.id
      render json: { error: 'You are not authorized to modify this ticket' }, status: :forbidden
    end
  end
end
