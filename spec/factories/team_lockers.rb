# frozen_string_literal: true

FactoryBot.define do
  factory :team_locker do
    team
    locker { association(:locker, company: team.company) }
  end
end
