class BookingsController < ApplicationController
  include JwtAuthentication
  include RoleAuthorization
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request!
  before_action :authorize_customer!
  before_action :set_booking, only: [:show, :update]

  def index
    @bookings = current_user.customer.bookings.includes(:event, :ticket)
    render json: @bookings, include: {
      event: { only: [:id, :title, :event_date, :venue] },
      ticket: { only: [:id, :ticket_type, :price] }
    }
  end

  def show
    render json: @booking, include: {
      event: { only: [:id, :title, :event_date, :venue] },
      ticket: { only: [:id, :ticket_type, :price] }
    }
  end

  def create
    @booking = current_user.customer.bookings.build(booking_params)
    @booking.booking_date = Time.current

    if validate_ticket_availability && @booking.save
      render json: @booking, status: :created
    else
      render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @booking.status == 'pending' && booking_params[:status] == 'cancelled'
      if @booking.update(status: 'cancelled')
        render json: @booking
      else
        render json: { errors: @booking.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid status transition' }, status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.customer.bookings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Booking not found' }, status: :not_found
  end

  def booking_params
    params.require(:booking).permit(:event_id, :ticket_id, :quantity, :status)
  end

  def validate_ticket_availability
    ticket = Ticket.find(booking_params[:ticket_id])
    
    if ticket.remaining < booking_params[:quantity].to_i
      @booking.errors.add(:quantity, 'exceeds available tickets')
      return false
    end
    
    true
  rescue ActiveRecord::RecordNotFound
    @booking.errors.add(:ticket_id, 'invalid ticket')
    false
  end
end
