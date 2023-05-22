class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :phone
      t.string :username
      t.string :status
      t.boolean :verified

      t.timestamps
    end
  end
end
