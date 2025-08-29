FactoryBot.define do
  factory :task do
    title { "test_task" }
    status { :todo }
    association :user
  end
end
