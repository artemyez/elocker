class CreateLockers < ActiveRecord::Migration[8.1]
  def change
    create_table :lockers do |t|
      t.references :company, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.string :identifier, null: false
      t.string :location, null: false
      t.string :state, null: false, default: "closed"

      t.timestamps
    end

    add_index :lockers, [ :company_id, :identifier ], unique: true
  end
end
