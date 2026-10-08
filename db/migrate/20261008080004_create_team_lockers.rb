# frozen_string_literal: true

class CreateTeamLockers < ActiveRecord::Migration[8.1]
  def change
    create_table :team_lockers do |t|
      t.references :team, null: false
      t.references :locker, null: false
      t.timestamps
    end
    add_index :team_lockers, %i[team_id locker_id], unique: true
  end
end
