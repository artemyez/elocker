class Locker < ApplicationRecord
  belongs_to :company
  has_many :team_lockers, dependent: :destroy
  has_many :teams, through: :team_lockers
  has_many :locker_actions, dependent: :restrict_with_error

  enum :state, { open: "open", closed: "closed" }, validate: true

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :identifier, presence: true, uniqueness: { scope: :company_id }
  validates :location, presence: true
end
