class TilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  def new
    @client = GithubService.new(current_user.github_token)
    @repositories = @client.list_repositories

    @selected_repo = params[:repo].presence
    if @selected_repo
      readme = @client.fetch_readme(@selected_repo)
      @readme_sha = readme[:sha]
      @readme_body = readme[:body]
    end
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  end

  def create
    # ✨ リポジトリ内にREADME.mdがない場合の処理も今後実装予定
    client = GithubService.new(current_user.github_token)
    client.update_readme(params[:repo], message: params[:message], new_body: params[:body], sha: params[:sha])
    redirect_to @task, notice: "GitHubにTILを反映しました"
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
end
