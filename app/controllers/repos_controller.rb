class ReposController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  def new
    @client = GithubService.new(current_user.github_token)
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  end

  def create
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def ensure_done
    redirect_to @task, alert: "完了したタスクのみリポジトリを作成できます" unless @task&.done?
  end
end
