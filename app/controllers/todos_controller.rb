class TodosController < ApplicationController
  before_action :set_todo, only: [ :update ]

  def update
    @todo.update(done: !@todo.done?) # 現在はtodoで変更できることはdoneカラムのトグルのみだが、今後bodyカラムも更新をする場合はここを変更する
    render partial: "todos/todo", locals: { todo: @todo }
  end

  private

  def set_todo
    @todo = current_user.tasks.find(params[:task_id]).todos.find(params[:id])
  end
end
