FactoryBot.define do
  factory :task do
    title { "task_title" }
    status { :todo }
    association :user
  end
end
