class Booking < ApplicationRecord
  belongs_to :customer
  belongs_to :event
  belongs_to :ticket

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :booking_date, presence: true
  validates :status, inclusion: { in: ['pending', 'confirmed', 'cancelled'] }
  
  before_validation :calculate_total_amount, on: :create
  after_create :update_ticket_remaining
  after_update :handle_status_change, if: :saved_change_to_status?

  private
  def calculate_total_amount
    if self.ticket && self.quantity
      self.total_amount = self.ticket.price * self.quantity
    end
  end
  
  def update_ticket_remaining
    if self.status == 'confirmed' && self.ticket
      self.ticket.update(remaining: self.ticket.remaining - self.quantity)
    end
  end
  
  def handle_status_change
    if self.status_previous_change[0] == 'confirmed' && self.status == 'cancelled'
      self.ticket.update(remaining: self.ticket.remaining + self.quantity)
    end
  end

end
