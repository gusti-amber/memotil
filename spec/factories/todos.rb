FactoryBot.define do
  factory :todo do
    association :task
    sequence(:body) { |n| "test_todo_#{n}" }
    done { false }
  end
end
