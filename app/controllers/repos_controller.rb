class ReposController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  def new
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
