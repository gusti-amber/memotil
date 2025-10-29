class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]
  def index
    @tasks = current_user.tasks.includes(:tags)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.order(created_at: :desc)
  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to @task, notice: "タスクが正常に作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @posts = @task.posts.includes(:user, :postable).order(created_at: :asc)
    @post = Post.new
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "タスクが正常に更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "タスクが削除されました。"
  end

  def toggle_status
    @task = current_user.tasks.find(params[:id])
    new_status = @task.doing? ? :done : :doing

    if @task.update(status: new_status)
      redirect_to @task, notice: "タスクのステータスが更新されました。"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, tag_ids: [], todos_attributes: [ :id, :body, :done, :_destroy ])
  end

  def set_task
    @task = current_user.tasks.includes(:tags, :posts, :todos).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end
end
