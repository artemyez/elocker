# frozen_string_literal: true

class AddUniqueCompanyNameIndexToLockers < ActiveRecord::Migration[8.1]
  def change
    add_index :lockers, %i[company_id name], unique: true
  end
end
