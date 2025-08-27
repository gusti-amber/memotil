FactoryBot.define do
  factory :tasktag do
    association :task
    association :tag
  end
end
