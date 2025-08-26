class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = current_user.tasks.includes(:tags).order(created_at: :desc)
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
    @task = current_user.tasks.includes(:tags, :posts, :todos).find(params[:id])
    @posts = @task.posts.includes(:user, :postable).order(created_at: :asc)
    @post = Post.new
  end

  def edit
    @task = current_user.tasks.includes(:tags, :todos).find(params[:id])
  end

  def update
    @task = current_user.tasks.find(params[:id])

    if @task.update(task_params)
      redirect_to @task, notice: "タスクが正常に更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def toggle_status
    @task = current_user.tasks.find(params[:id])
    new_status = @task.done? ? :doing : :done

    if @task.update(status: new_status)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def task_params
    params.require(:task).permit(:title, tag_ids: [], todos_attributes: [ :id, :body, :done, :_destroy ])
  end
end
