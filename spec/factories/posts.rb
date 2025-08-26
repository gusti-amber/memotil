FactoryBot.define do
  factory :post do
    association :user
    association :task
    postable_type { "TextPost" }
    postable_id { create(:text_post).id }
  end
end
