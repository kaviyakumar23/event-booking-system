class Organizer < ApplicationRecord
  belongs_to :user
  has_many :events

  validates :user_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :phone, presence: true
end
