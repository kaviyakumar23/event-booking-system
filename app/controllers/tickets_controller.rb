class TicketsController < ApplicationController
  include JwtAuthentication
  include RoleAuthorization
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action :set_ticket, only: [:show, :update, :destroy]
  before_action :authorize_event_organizer!, only: [:create, :update, :destroy]
  before_action :authorize_ticket_access!, only: [:update, :destroy]

  def index
    begin
      @event = Event.find(params[:event_id])
      @tickets = @event.tickets
      render json: @tickets
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("Event not found: #{params[:event_id]}")
      render json: { error: 'Event not found' }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error fetching tickets: #{e.message}")
      render json: { error: 'An error occurred while fetching tickets' }, status: :internal_server_error
    end
  end

  def show
    render json: @ticket
  end

  def create
    begin
      @event = Event.find(params[:event_id])
      
      # Ensure the current user owns the event
      unless @event.event_organizer_id == current_user.event_organizer.id
        Rails.logger.warn("Unauthorized ticket creation attempt for event #{params[:event_id]} by organizer #{current_user.event_organizer.id}")
        return render json: { error: 'Unauthorized to create tickets for this event' }, status: :forbidden
      end

      @ticket = @event.tickets.build(ticket_params)

      if @ticket.save
        Rails.logger.info("Ticket created: #{@ticket.id} for event #{@event.id}")
        render json: @ticket, status: :created
      else
        Rails.logger.warn("Ticket creation failed: #{@ticket.errors.full_messages}")
        render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("Event not found: #{params[:event_id]}")
      render json: { error: 'Event not found' }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error creating ticket: #{e.message}")
      render json: { error: 'An error occurred while creating the ticket' }, status: :internal_server_error
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
