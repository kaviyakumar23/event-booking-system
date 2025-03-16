class EventUpdateNotificationJob
  include Sidekiq::Job

  def perform(event_id, changes)
    event = Event.find(event_id)
    
    # Find all bookings for this event
    bookings = event.bookings.includes(:customer)
    
    # Send notification to each customer
    bookings.each do |booking|
      BookingMailer.event_update_notification(booking.id, changes).deliver_now
    end
  rescue ActiveRecord::RecordNotFound => e
    puts "Event #{event_id} not found"
  rescue StandardError => e
    puts "Error sending event update notifications: #{e.message}"
  end
end 