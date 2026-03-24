FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "test_tag_#{n}" }
    user_id { nil }

    trait :for_user do
      association :user
    end
  end
end
