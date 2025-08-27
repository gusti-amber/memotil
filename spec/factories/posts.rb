FactoryBot.define do
  factory :post do
    association :user
    association :task
    association :postable
  end
end
