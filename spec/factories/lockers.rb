# frozen_string_literal: true

FactoryBot.define do
  factory :locker do
    company
    sequence(:name) { |n| "Warehouse gate #{n}" }
    sequence(:identifier) { |n| "GATE-#{n}" }
    location { 'Berlin warehouse, entrance' }
    state { 'closed' }

    trait :open do
      state { 'open' }
    end

    trait :closed do
      state { 'closed' }
    end
  end
end
