class TeamLocker < ApplicationRecord
  belongs_to :team
  belongs_to :locker

  validates :locker, uniqueness: { scope: :team }
  validate :same_company

  private

  def same_company
    return unless team && locker

    if team.company_id != locker.company_id
      errors.add(:locker, "must belong to the same company as the team")
    end
  end
end
