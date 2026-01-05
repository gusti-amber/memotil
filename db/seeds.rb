# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

tag_names = [
  # 概念
  "アルゴリズム", "UI/UX", "セキュリティ", "パフォーマンス", "テスト", "設計",

  # 行動・作業
  "実装", "デバッグ", "リファクタリング", "調査", "読書",

  # Programming Languages
  "JavaScript", "TypeScript", "Python", "Ruby", "PHP",
  "Go", "Rust", "Java", "C#", "Shell",

  # Frameworks
  "React", "Vue.js", "Next.js", "Nuxt",
  "Angular", "Express", "Django", "FastAPI",
  "Rails", "Laravel", "Spring Boot",

  # Databases
  "PostgreSQL", "MySQL", "MongoDB", "SQLite",
  "Oracle", "Redis", "Firebase", "SQL", "DynamoDB",

  # Infrastructure / Cloud
  "AWS", "Azure", "GoogleCloud",
  "Docker", "Docker Compose", "Kubernetes",
  "Terraform", "Heroku",
  "Cloudflare", "Netlify", "Vercel",
  "Lambda", "EC2", "S3", "Nginx",

  # Development Tools
  "Git", "GitHub", "GitHub Actions", "CI/CD",
  "VSCode", "Vim",
  "ESLint", "Prettier", "Webpack", "Vite",
  "npm", "Yarn", "pnpm",
  "Postman", "Slack", "Bash", "Zsh"
]


tag_names.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end

# 開発環境でのテストデータ作成
if Rails.env.development?
  # テスト用ユーザーの作成
  test_user = User.find_or_create_by!(email: "test@example.com") do |user|
    user.name = "test_user"
    user.password = "password"
    user.password_confirmation = "password"
  end

  # 既存のタスクを削除してから新規作成（開発環境でのみ）
  if test_user.tasks.count < 100
    test_user.tasks.destroy_all
    tags = Tag.all

    # 100件のタスクを作成
    100.times do |i|
      task = test_user.tasks.create!(
        title: "test_task_#{i + 1}",
        status: [ :todo, :doing, :done ].sample,
        created_at: rand(30.days).seconds.ago
      )

      # ランダムに1〜5個のタグを紐づけ
      task.tags << tags.sample(rand(1..5))
    end
  end
end
