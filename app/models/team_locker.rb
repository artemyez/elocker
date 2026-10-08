class TeamLocker < ApplicationRecord
  belongs_to :team
  belongs_to :locker
  belongs_to :company
end
