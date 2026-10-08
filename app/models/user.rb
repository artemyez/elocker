# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :team, optional: true
  has_one :company, through: :team

  enum :role, { employee: 'employee', support: 'support' }, validate: true
end
