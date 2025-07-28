FactoryBot.define do
  factory :post do
    task { nil }
    user { nil }
    postable_type { "MyString" }
    postable_id { 1 }
  end
end
