class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.references :ticket, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.datetime :booking_date, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
  end
end
