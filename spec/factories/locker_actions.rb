# frozen_string_literal: true

FactoryBot.define do
  factory :locker_action do
    association :locker
    association :user
    action { 'open' }
    occurred_at { Time.current }

    trait :close do
      action { 'close' }
    end
  end
end
