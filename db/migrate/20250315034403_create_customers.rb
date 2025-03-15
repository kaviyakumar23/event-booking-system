class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.references :user, foreign_key: true
        t.string :name
        t.string :phone

      t.timestamps
    end
  end
end
