class BookingConfirmationJob
  include Sidekiq::Job

  def perform(booking_id)
    BookingMailer.booking_confirmation(booking_id).deliver_now
  rescue ActiveRecord::RecordNotFound => e
    puts "Booking #{booking_id} not found"
  rescue StandardError => e
    puts "Error sending booking confirmation: #{e.message}"
  end
end 