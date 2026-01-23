class GithubService
  def initialize(access_token)
    @client = Octokit::Client.new(access_token: access_token)
  end

  def list_repositories
    # 🎓 GitHub API のリポジトリ一覧取得方法: https://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#repositories-instance_method
    @client.repos(nil, per_page: 100)
  end

  def create_contents(repo, path:, message:, content:)
    # 🎓 create_contentsメソッドは位置引数を取るので注意（キーワード引数ではない）
    # 公式ドキュメント: https://www.rubydoc.info/gems/octokit/10.0.0/Octokit/Client/Contents#create_contents-instance_method
    @client.create_contents(
      repo, # GitHubのリポジトリ
      path, # 作成するコンテンツのパス
      message, # コンテンツ作成時のコミットメッセージ
      content # 作成するコンテンツの内容
    )
  end

  def file_exists?(repo, path:)
    # 🎓 contentsメソッドでファイルの存在を確認
    # 公式ドキュメント: https://octokit.github.io/octokit.rb/Octokit/Client/Contents.html#contents-instance_method
    @client.contents(repo, path: path)
    true
  rescue Octokit::NotFound
    false
  end

  def create_repository(name:, description: nil, private: "false", auto_init: false)
    # 🎓 create_repositoryメソッドでリポジトリを作成
    # 公式ドキュメント: https://www.rubydoc.info/gems/octokit/10.0.0/Octokit/Client/Repositories#create_repository-instance_method
    # リポジトリ名のみを指定すると、認証済みユーザーのアカウント直下に作成される
    # private, has_issues, has_wiki, has_downloadsはString型（"true"または"false"）を期待
    # auto_initはBoolean型を期待
    options = {
      description: description,
      private: private,  # String型に変換（"true"または"false"）
      auto_init: auto_init,
      has_issues: "true",
      has_wiki: "false",
      has_downloads: "false",
      gitignore_template: nil
    }
    @client.create_repository(name, options)
  end

  def repository_exists?(repo)
    # 🎓 GitHub API のユーザー情報取得方法: https://octokit.github.io/octokit.rb/Octokit/Client/Users.html#user-instance_method
    owner = @client.user.login
    # 🎓 repositoryメソッドでリポジトリの存在を確認
    # 公式ドキュメント: https://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#repository-instance_method
    full_name = "#{owner}/#{repo}"
    @client.repository(full_name)
    true
  rescue Octokit::NotFound
    false
  end
end
