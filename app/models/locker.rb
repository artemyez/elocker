# frozen_string_literal: true

class Locker < ApplicationRecord
  belongs_to :company
  has_many :team_lockers, dependent: :destroy
  has_many :teams, through: :team_lockers
  has_many :locker_actions, dependent: :restrict_with_error

  enum :state, { open: 'open', closed: 'closed' }, validate: true

  validates :name, :identifier, :location, presence: true
  validates :name, :identifier, uniqueness: { scope: :company_id }

  def open(user)
    perform_transition(target_state: 'open', action_name: 'open', user: user)
  end

  def close(user)
    perform_transition(target_state: 'closed', action_name: 'close', user: user)
  end

  private

  def perform_transition(target_state:, action_name:, user:)
    with_lock do
      return false if state == target_state

      update!(state: target_state)
      locker_actions.create!(user: user, action: action_name, occurred_at: Time.current)
      true
    end
  end
end
