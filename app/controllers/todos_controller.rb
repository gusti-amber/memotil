class TodosController < ApplicationController
  before_action :set_todo, only: [ :update ]

  def update
    if @todo.update(done: !@todo.done?)
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @todo.task, notice: "Todoが正常に更新されました。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.html { redirect_to @todo.task, alert: "Todoの更新に失敗しました。" }
      end
    end
  end

  private

  def set_todo
    @todo = current_user.tasks.find(params[:task_id]).todos.find(params[:id])
  end
end
