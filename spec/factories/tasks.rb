FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "test_task_#{n}" }
    status { :doing }
    association :user
  end

  factory :todo_task, parent: :task do
    status { :todo }
  end

  factory :doing_task, parent: :task do
    status { :doing }
  end

  factory :done_task, parent: :task do
    status { :done }
  end
end
