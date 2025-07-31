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
  # Programming Languages
  "JavaScript", "TypeScript", "Python", "Ruby", "PHP", "Go", "Rust", "Java", "C#", "Shell",

  # Frameworks
  "React", "Vue.js", "Next.js", "Nuxt", "Angular", "Express", "FastAPI", "Django", "Rails", "Laravel", "Spring Boot",

  # Databases
  "PostgreSQL", "MySQL", "MongoDB", "SQLite", "Oracle", "Redis", "Firebase", "SQL",

  # Infrastructure / Cloud
  "AWS", "Azure", "GoogleCloud", "Docker", "Docker Compose", "Kubernetes", "Terraform", "Vagrant",
  "Heroku", "Netlify", "Vercel", "Cloudflare", "Lambda", "EC2", "S3",

  # Development Tools
  "Git", "GitHub", "GitHub-Actions", "CI-CD", "Jenkins", "ESLint", "Prettier", "Webpack",
  "pnpm", "Yarn", "Vite", "VSCode", "Vim", "Slack", "Zsh", "Bash", "Postman",

  # Rails Gems
  "Devise", "Capistrano", "CarrierWave", "RSpec", "Kaminari", "Pundit", "ActiveAdmin", "Sidekiq"
]

tag_names.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end
