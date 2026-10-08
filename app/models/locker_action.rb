class LockerAction < ApplicationRecord
  belongs_to :locker
  belongs_to :user

  enum :action, { open: "open", close: "close" }, validate: true

  validates :occurred_at, presence: true
end
