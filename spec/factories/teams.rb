# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    company
    sequence(:name) { |n| "Team #{n}" }
  end
end
