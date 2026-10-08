class Company < ApplicationRecord
  has_many :teams, dependent: :restrict_with_error
  has_many :lockers, dependent: :restrict_with_error

  validates :name, presence: true
end
