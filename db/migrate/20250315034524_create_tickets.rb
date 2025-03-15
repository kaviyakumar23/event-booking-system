class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.references :event, null: false, foreign_key: true
      t.string :ticket_type, null: false
      t.integer :price, null: false  # Price in cents/pennies
      t.integer :quantity, null: false
      t.integer :remaining, null: false

      t.timestamps
    end
  end
end
