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
      Rails.logger.info("Event created: #{@event.id} by organizer #{current_user.event_organizer.id}")
      render json: @event, status: :created
    else
      Rails.logger.warn("Event creation failed: #{@event.errors.full_messages}")
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("Error creating event: #{e.message}")
    render json: { error: 'An error occurred while creating the event' }, status: :internal_server_error
  end

  def update
    begin
      changes = {}
      event_params.each do |param, value|
        changes[param] = value if @event.send(param) != value
      end

      if @event.update(event_params)
        # Only send notifications if there are changes
        if changes.present?
          EventUpdateNotificationJob.perform_async(@event.id, changes)
          Rails.logger.info("Event updated: #{@event.id} with changes: #{changes}")
        end
        render json: @event
      else
        Rails.logger.warn("Event update failed: #{@event.errors.full_messages}")
        render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error("Error updating event: #{e.message}")
      render json: { error: 'An error occurred while updating the event' }, status: :internal_server_error
    end
  end

  def destroy
    begin
      if @event.bookings.exists?
        Rails.logger.info("Event deletion rejected - has bookings: #{@event.id}")
        render json: { error: 'Cannot delete event with existing bookings' }, status: :unprocessable_entity
      else
        @event.destroy
        Rails.logger.info("Event deleted: #{@event.id}")
        head :no_content
      end
    rescue StandardError => e
      Rails.logger.error("Error deleting event: #{e.message}")
      render json: { error: 'An error occurred while deleting the event' }, status: :internal_server_error
    end
  end

  private

  def set_event
    @event = Event.includes(:event_organizer, :tickets).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end

  def event_params
    permitted = params.require(:event).permit(
      :title,
      :description,
      :event_date,
      :venue,
      :venue_address,
      :status
    )
    
    # Check for unpermitted parameters
    unpermitted = params[:event].keys - permitted.keys
    if unpermitted.any?
      raise ActionController::ParameterMissing.new("Unpermitted parameters: #{unpermitted.join(', ')}")
    end

    permitted
  end

  def authorize_event_access!
    unless @event.event_organizer_id == current_user.event_organizer.id
      render json: { error: 'You are not authorized to modify this event' }, status: :forbidden
    end
  end
end
