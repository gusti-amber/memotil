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
    # フォームの入力値を保持するため、インスタンス変数に保存
    @path = params[:path]
    @message = params[:message]
    @body = params[:body]

    # パス名のバリデーション
    @validation_error = validate_path(@path)
    if @validation_error
      prepare_new_view
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
      return
    end

    client = GithubService.new(current_user.github_token)
    client.create_contents(
      params[:repo],
      path: @path,
      message: @message,
      content: @body
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

  def validate_path(path)
    return "パス名を入力してください" if path.blank? || path.strip.empty?
    return "パス名は.mdで終わる必要があります" unless path.end_with?('.md')
    return "パス名に使用できない文字( : \* ? \" < > | )が含まれています" if contains_forbidden_characters?(path)
    return "不正なパス名が指定されています" if contains_invalid_location?(path)
    return "指定したパス名はすでに存在しています" if file_already_exists?(path)

    nil
  end

  def contains_forbidden_characters?(path)
    forbidden_chars = /[:*?"<>|]/
    path.match?(forbidden_chars)
  end

  def contains_invalid_location?(path)
    invalid_patterns = [
      path.include?('..'),           # 親ディレクトリ参照
      path.include?('//'),           # 連続するスラッシュ
      path.start_with?('/'),         # 絶対パス
      path.include?('.git/'),        # .gitディレクトリ内
      path.start_with?('.git')       # .gitで始まるパス
    ]
    invalid_patterns.any?
  end

  def file_already_exists?(path)
    client = GithubService.new(current_user.github_token)
    client.file_exists?(params[:repo], path: path)
  end

  # 再レンダリング時のパラメータを保持
  def prepare_new_view
    @client = GithubService.new(current_user.github_token)
    @repositories = @client.list_repositories
    @selected_repo = params[:repo].presence
  end
end
