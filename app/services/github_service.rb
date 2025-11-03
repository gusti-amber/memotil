class GithubService
  def initialize(access_token)
    @client = Octokit::Client.new(access_token: access_token)
  end

  def list_repositories
    # 🎓 GitHub API のリポジトリ一覧取得方法: https://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html#repositories-instance_method
    @client.repos(nil, per_page: 100)
  end

  def fetch_readme(repo)
    readme = @client.contents(repo, path: "README.md")

    # 取得したREADME.mdをBase64でデコードし、UTF-8でエンコード
    body = Base64.decode64(readme[:content]).force_encoding('UTF-8')
    { sha: readme[:sha], body: body }
  rescue Octokit::NotFound
    { sha: nil, body: "" }
  end
end


