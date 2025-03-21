class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
        t.string :password_digest
        t.string :role
        t.datetime :last_signin_at

      t.timestamps
    end
  end
end
