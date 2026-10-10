# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    team
    sequence(:name) { |n| "Employee #{n}" }
    sequence(:email) { |n| "employee#{n}@example.com" }
    role { 'employee' }

    trait :employee do
      role { 'employee' }
    end

    trait :support do
      role { 'support' }
      team { nil }
    end
  end
end
