FactoryBot.define do
  factory :document do
    sequence(:url) { |n| "https://docs.example.com/#{n}" }
  end
end
