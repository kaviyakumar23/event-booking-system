class EventsController < ApplicationController
  include JwtAuthentication
  include RoleAuthorization
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action :set_event, only: [:show, :update, :destroy]
  before_action :authorize_event_organizer!, only: [:create, :update, :destroy]
  before_action :authorize_event_access!, only: [:update, :destroy]

  def index
    @events = Event.includes(:event_organizer, :tickets)
    
    # Filter by status if present
    @events = @events.where(status: params[:status]) if params[:status].present?
    
    # Filter by date range if present
    if params[:start_date].present? && params[:end_date].present?
      @events = @events.where(event_date: params[:start_date]..params[:end_date])
    end

    render json: @events, include: {
      event_organizer: { only: [:id, :name, :company_name] },
      tickets: { except: [:created_at, :updated_at] }
    }
  end

  def show
    render json: @event, include: {
      event_organizer: { only: [:id, :name, :company_name] },
      tickets: { except: [:created_at, :updated_at] }
    }
  end

  def create
    @event = current_user.event_organizer.events.build(event_params)

    if @event.save
      render json: @event, status: :created
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    changes = {}
    event_params.each do |param, value|
      changes[param] = value if @event.send(param) != value
    end

    if @event.update(event_params)
      # Only send notifications if there are changes
      if changes.present?
        EventUpdateNotificationJob.perform_async(@event.id, changes)
      end
      render json: @event
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @event.bookings.exists?
      render json: { error: 'Cannot delete event with existing bookings' }, status: :unprocessable_entity
    else
      @event.destroy
      head :no_content
    end
  end

  private

  def set_event
    @event = Event.includes(:event_organizer, :tickets).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :event_date,
      :venue,
      :venue_address,
      :status
    )
  end

  def authorize_event_access!
    unless @event.event_organizer_id == current_user.event_organizer.id
      render json: { error: 'You are not authorized to modify this event' }, status: :forbidden
    end
  end
end
