class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]
  def index
    @search_params = search_params
    @q = current_user.tasks.ransack(@search_params)
    @tasks = @q.result
                .includes(:tags)
                .order(created_at: :desc)
                .page(params[:page]).per(24)
    @tags = Tag.all
  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to @task, notice: t("flash.tasks.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    order_direction = @task.doing? ? :desc : :asc
    @posts = @task.posts.includes(:user, :postable).order(created_at: order_direction)
    @post = Post.new
  end

  def edit
  end

  def update
    if @task.update(task_params)
      # todo_formからのリクエストかどうかを判別
      if from_todo_form?
        # todo_formからのリクエストの場合、Turbo Streamでtodo_sectionを更新
        respond_to do |format|
          format.turbo_stream
          format.html do
            @posts = @task.posts.includes(:user, :postable).order(created_at: :asc)
            @post = Post.new
            render :show, status: :ok
          end
        end
      else
        # edit.html.erbからのリクエストの場合、リダイレクト
        redirect_to @task, notice: t("flash.tasks.update")
      end
    else
      # エラー時も同様に判別
      if from_todo_form?
        respond_to do |format|
          format.turbo_stream { render :update, status: :unprocessable_entity }
          format.html do
            @posts = @task.posts.includes(:user, :postable).order(created_at: :asc)
            @post = Post.new
            render :show, status: :unprocessable_entity
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: t("flash.tasks.destroy")
  end

  def toggle_status
    @task = current_user.tasks.find(params[:id])
    new_status = @task.doing? ? :done : :doing

    if @task.update(status: new_status)
      redirect_to @task, notice: t("flash.tasks.status_changed")
    else
      render :show, status: :unprocessable_entity
    end
  end

  def autocomplete
    query = params[:query].to_s.strip

    return render json: { tasks: [] } if query.length < 2

    tasks = current_user.tasks
                        .where("LOWER(title) LIKE ?", "%#{query.downcase}%")
                        .limit(10)
                        .select(:id, :title)
                        .order(created_at: :desc)

    # 🎓 オブジェクトからJSON形式に変換しレンダリングする方法: https://railsguides.jp/v7.2/layouts_and_rendering.html#json%E3%82%92%E3%83%AC%E3%83%B3%E3%83%80%E3%83%AA%E3%83%B3%E3%82%B0%E3%81%99%E3%82%8B
    render json: { tasks: tasks }
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, tag_ids: [], todos_attributes: [ :id, :body, :done, :_destroy ])
  end

  def search_params
    return {} unless params[:q]
    params[:q].permit(:status_eq, :tags_name_eq, :title_cont)
  end

  def set_task
    @task = current_user.tasks.includes(:tags, :posts, :todos).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def from_todo_form?
    # todos_attributesパラメータが存在し、かつ値がある場合、todo_formからのリクエストと判断
    params[:task] && params[:task][:todos_attributes].present?
  end
end
