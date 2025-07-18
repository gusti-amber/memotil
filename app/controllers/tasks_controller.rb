class TasksController < ApplicationController
  def index
    @tasks = current_or_guest_user.tasks.includes(:tags).order(created_at: :desc)
  end

  def new
    @task = current_or_guest_user.tasks.build
  end

  def create
    @task = current_or_guest_user.tasks.build(task_params)

    if @task.save
      redirect_to @task, notice: "タスクが正常に作成されました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @task = current_or_guest_user.tasks.includes(:tags).find(params[:id])
  end

  def edit
    @task = current_or_guest_user.tasks.includes(:tags, :todos).find(params[:id])
  end

  def update
    @task = current_or_guest_user.tasks.find(params[:id])

    if @task.update(task_params)
      redirect_to @task, notice: "タスクが正常に更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  def task_params
    params.require(:task).permit(:title, tag_ids: [], todos_attributes: [ :id, :body, :done, :_destroy ])
  end
end
