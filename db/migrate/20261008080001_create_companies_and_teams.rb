# frozen_string_literal: true

class CreateCompaniesAndTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :teams do |t|
      t.references :company, null: false, foreign_key: { on_delete: :restrict }
      t.string :name, null: false
      t.timestamps
      t.index %i[company_id name], unique: true
    end
  end
end
