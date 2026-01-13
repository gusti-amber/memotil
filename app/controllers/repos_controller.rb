class ReposController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task

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
end
