class DummyDataCreatorService
  def initialize(user)
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      create_dummy_task
    end
  end

  private

  def create_dummy_task
    # タスクを作成
    task = @user.tasks.create!(
      title: "見本: AtCoder Beginner Contest 439 の A~C問題を解く",
      status: :doing
    )

    # タグを取得して紐付け
    ruby_tag = Tag.find_or_create_by!(name: "Ruby")
    algorithm_tag = Tag.find_or_create_by!(name: "アルゴリズム")
    task.tags << [ ruby_tag, algorithm_tag ]

    # Todoを5件作成
    todos_data = [
      { body: "A問題を解く", done: true },
      { body: "B問題を解く", done: true },
      { body: "C問題を解く", done: false },
      { body: "模範解答を見て解法を理解する", done: false },
      { body: "模範解答をもとにコードを書く", done: false }
    ]

    todos_data.each do |todo_data|
      task.todos.create!(todo_data)
    end

    # Documentを2件作成（または既存を取得）
    document_urls = [
      "https://atcoder.jp/contests/abc439/tasks/abc439_a",
      "https://atcoder.jp/contests/abc439/tasks/abc439_b"
    ]

    document_urls.each do |url|
      document = Document.find_or_create_by!(url: url)

      # DocumentPostを作成
      document_post = DocumentPost.create!(document: document)

      # Postを作成（DocumentPostと紐付け）
      task.posts.create!(
        user: @user,
        postable: document_post
      )
    end

    # コードスニペットとメモをTextPostとして作成
    code_snippet_a = <<~RUBY
      ```ruby
      n = gets.to_i
      puts 2**n - 2*n
      ```
    RUBY

    code_snippet_b = <<~RUBY
      ```ruby
      nums = gets.split("").map(&:to_i)

      def foo(nums)
        tmp = nums.map{ |x| x**2 }
        total = tmp.sum

        total.to_s.split("").map(&:to_i)
      end

      300.times do
        if nums.sum == 1
          puts "Yes"
          return
        end
        nums = foo(nums)
      end

      puts "No"
      ```
    RUBY

    text_posts_data = [
      "A問題",
      code_snippet_a.strip,
      "B問題",
      code_snippet_b.strip,
      "foo: numsの各桁の二乗和を計算し、各桁に分解した配列を返す"
    ]

    text_posts_data.each do |body|
      text_post = TextPost.create!(body: body)

      # Postを作成（TextPostと紐付け）
      task.posts.create!(
        user: @user,
        postable: text_post
      )
    end

    task
  end
end
