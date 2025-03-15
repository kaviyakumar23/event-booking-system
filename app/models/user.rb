class User < ApplicationRecord
    has_secure_password

    has_one :organizer, dependent: :destroy
    has_one :customer, dependent: :destroy

    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 8 }
    validates :role, presence: true, inclusion: { in: ['organizer', 'customer'] }
end
