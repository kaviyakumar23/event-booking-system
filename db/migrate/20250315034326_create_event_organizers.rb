class CreateEventOrganizers < ActiveRecord::Migration[7.1]
  def change
    create_table :event_organizers do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :phone
      t.string :company_name
      
      t.timestamps
    end
  end
end 