class Ticket < ApplicationRecord
  belongs_to :event
  has_many :bookings

  validates :ticket_type, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :remaining, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_initial_remaining, on: :create

  private

  def set_initial_remaining
    self.remaining = quantity if self.remaining.nil?
  end
end
