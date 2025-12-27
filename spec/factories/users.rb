FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "test_user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    # confirmableモジュールが有効なため、テスト用ユーザーは確認済みとして扱う
    confirmed_at { Time.current }
  end

  factory :guest_user, parent: :user do
    name { "guest" }
    sequence(:email) { |n| "guest_#{Time.now.to_i}#{n}@example.com" }
    # ゲストユーザーはバリデーションをスキップして作成される
    to_create { |guest_user| guest_user.save!(validate: false) }
  end

  factory :unconfirmed_user, parent: :user do
    sequence(:email) { |n| "unconfirmed_#{n}@example.com" }
    confirmed_at { nil }
  end
end
