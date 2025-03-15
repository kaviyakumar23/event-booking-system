class Event < ApplicationRecord
  belongs_to :event_organizer
  has_many :tickets
  has_many :bookings

  validates :title, presence: true
  validates :description, presence: true
  validates :event_date, presence: true
  validates :venue, presence: true
  validates :venue_address, presence: true
  validates :status, inclusion: { in: ['active', 'cancelled', 'completed'] }
  
end