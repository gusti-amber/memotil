class TilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task

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

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end
end


