FactoryBot.define do
  factory :task do
    user { nil }
    title { "MyString" }
    status { 1 }
  end
end
