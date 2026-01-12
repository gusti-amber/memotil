class TilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  # 将来的な実装: README.md編集機能
  # def edit
  #   @client = GithubService.new(current_user.github_token)
  #   @repositories = @client.list_repositories
  #
  #   @selected_repo = params[:repo].presence
  #   if @selected_repo
  #     readme = @client.fetch_readme(@selected_repo)
  #     @readme_sha = readme[:sha]
  #     @readme_body = readme[:body]
  #   end
  # rescue Octokit::Unauthorized
  #   redirect_to @task, alert: "GitHub連携が必要です"
  # end
  #
  # def update
  #   # ✨ リポジトリ内にREADME.mdがない場合の処理も今後実装予定
  #   client = GithubService.new(current_user.github_token)
  #   client.update_readme(params[:repo], message: params[:message], new_body: params[:body], sha: params[:sha])
  #   redirect_to @task, notice: "GitHubリポジトリにTILを保存しました"
  # end

  def new
    @client = GithubService.new(current_user.github_token)
    @repositories = @client.list_repositories

    @selected_repo = params[:repo].presence
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  end

  def create
    path = params[:path]

    # パス名のバリデーション
    # パス名が空の場合
    if path.blank? || path.strip.empty?
      redirect_to new_task_til_path(@task, repo: params[:repo]), alert: "パス名を入力してください"
      return
    end

    # パス名の末尾が.mdではない場合
    unless path.end_with?('.md')
      redirect_to new_task_til_path(@task, repo: params[:repo]), alert: "パス名は.mdで終わる必要があります"
      return
    end

    # パス名が禁止文字を含む場合
    if contains_forbidden_characters?(path)
      redirect_to new_task_til_path(@task, repo: params[:repo]), alert: "パス名に使用できない文字( : \* ? \" < > | )が含まれています"
      return
    end

    # パス名が不正な場合
    if contains_invalid_location?(path)
      redirect_to new_task_til_path(@task, repo: params[:repo]), alert: "不正なパス名が指定されています"
      return
    end

    client = GithubService.new(current_user.github_token)
    client.create_contents(
      params[:repo],
      path: path,
      message: params[:message],
      content: params[:body]
    )
    redirect_to @task, notice: "新しいmdファイルにTILを記録しました"
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  rescue Octokit::UnprocessableEntity => e
    redirect_to new_task_til_path(@task, repo: params[:repo]), alert: "ファイルの作成に失敗しました: #{e.message}"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def ensure_done
    redirect_to @task, alert: "完了したタスクのみTILを反映できます" unless @task&.done?
  end

  def contains_forbidden_characters?(path)
    forbidden_chars = /[:*?"<>|]/
    path.match?(forbidden_chars)
  end
  
  def contains_invalid_location?(path)
    path.include?('..') || path.include?('.git/') || path.start_with?('.git')
  end
end
