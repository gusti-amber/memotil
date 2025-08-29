FactoryBot.define do
  factory :text_post do
    sequence(:body) { |n| "test_text_post_#{n}" }
  end
end
