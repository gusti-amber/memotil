FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "test_tag_#{n}" }
  end
end
