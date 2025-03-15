class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.references :organizer, foreign_key: { to_table: :users }
        t.string :title
        t.text :description
        t.datetime :event_date
        t.string :venue
        t.string :venue_address
        t.string :status

      t.timestamps
    end
  end
end
