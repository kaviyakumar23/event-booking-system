class BookingMailer < ApplicationMailer
  def booking_confirmation(booking_id)
    @booking = Booking.find(booking_id)
    @customer = @booking.customer
    @event = @booking.event
    
    puts "Sending booking confirmation email to #{@customer.user.email} for event: #{@event.title}"
  end

  def event_update_notification(booking_id, changes)
    @booking = Booking.find(booking_id)
    @customer = @booking.customer
    @event = @booking.event
    @changes = changes
    
    puts "Sending event update notification to #{@customer.user.email} for event: #{@event.title}"
    puts "Changes made: #{@changes}"
  end
end
