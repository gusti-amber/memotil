FactoryBot.define do
  factory :todo do
    task { nil }
    body { "MyString" }
    done { false }
  end
end
