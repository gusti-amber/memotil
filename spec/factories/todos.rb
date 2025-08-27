FactoryBot.define do
  factory :todo do
    association :task
    body { "todo_body" }
    done { false }
  end
end
