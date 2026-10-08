# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :company
  has_many :users, dependent: :restrict_with_error
  has_many :team_lockers, dependent: :restrict_with_error
  has_many :lockers, through: :team_lockers

  validates :name, presence: true, uniqueness: { scope: :company_id }
end
