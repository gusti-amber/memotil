FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "test_task_#{n}" }
    status { :doing }
    association :user
  end
end
