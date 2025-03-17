class User < ApplicationRecord
    has_secure_password

    has_one :event_organizer, dependent: :destroy
    has_one :customer, dependent: :destroy

    validates :email, presence: true, uniqueness: true, 
                     format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, message: "must be a valid email address" }
    validates :password, presence: true, length: { minimum: 8 }
    validates :role, presence: true, inclusion: { in: ['event_organizer', 'customer'] }
end
