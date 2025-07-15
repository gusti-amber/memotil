class TasksController < ApplicationController
  def index
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
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def task_params
    params.require(:task).permit(:title, tag_ids: [])
  end
end
