class CreateLockerActions < ActiveRecord::Migration[8.1]
  def change
    create_table :locker_actions do |t|
      t.references :locker, null: false, foreign_key: { on_delete: :restrict }
      t.references :user, null: false, foreign_key: { on_delete: :restrict }
      t.string :action, null: false
      t.datetime :occurred_at, null: false
      t.timestamps
    end
  end
end
