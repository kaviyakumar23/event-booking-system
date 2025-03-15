class Customer < ApplicationRecord
  belongs_to :user
  has_many :bookings

  validates :user_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :phone, presence: true
end
