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
  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = current_user.tasks.build(task_attributes_for_save)

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
    if @task.update(task_attributes_for_save)
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

  # モデルにパラメータを渡す前に、tag_idsを解決する処理
  def task_attributes_for_save
    # new_tag_namesをtask_paramsから除外する。
    base = task_params.except(:new_tag_names)
    return base if from_todo_form?

    # tag_idsを解決する。new_tag_namesから新しいTagを作成し、そのIDをtag_idsに追加する処理
    # task#create, task#updateではtag_idsを渡すことにより、Taskに紐づくTagの更新を行う。
    base.merge(tag_ids: resolve_tag_ids_for_task)
  end

  def task_params
    params.require(:task).permit(:title, :description, tag_ids: [], new_tag_names: [], todos_attributes: [ :id, :body, :done, :_destroy ])
  end

  def resolve_tag_ids_for_task
    ids = Array(params.dig(:task, :tag_ids)).map(&:to_i).reject(&:zero?).uniq
    names = Array(params.dig(:task, :new_tag_names)).map(&:strip).reject(&:blank?).uniq

    # new_tag_namesから新しいTagを作成し、そのIDをtag_idsに追加する処理
    names.each do |name|
      tag = find_or_create_tag_for_current_user(name)
      ids << tag.id if tag
    end
    ids.uniq
  end

  def find_or_create_tag_for_current_user(name)
    tag = Tag.for_user(current_user).where("lower(name) = ?", name.downcase).first
    return tag if tag

    Tag.create!(user: current_user, name: name)
  rescue ActiveRecord::RecordInvalid
    Tag.for_user(current_user).where("lower(name) = ?", name.downcase).first
  end

  def search_params
    return {} unless params[:q]
    params[:q].permit(:status_eq, :title_cont)
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
