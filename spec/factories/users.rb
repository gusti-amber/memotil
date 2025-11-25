FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "test_user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    # confirmableモジュールが有効なため、テスト用ユーザーは確認済みとして扱う
    confirmed_at { Time.current }
  end
end
