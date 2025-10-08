class PostsController < ApplicationController
  before_action :set_task
  before_action :set_post, only: [ :destroy ]

  def create
    # ネストした属性を使用して一度に作成
    if post_params[:postable_type] == "DocumentPost"
      document_url = post_params[:postable_attributes][:url]
      document = Document.new(url: document_url)
      
      # Documentのバリデーションを実行
      unless document.valid?
        @post = @task.posts.build(
          user: current_user,
          postable_type: post_params[:postable_type],
          postable_attributes: { document: document }
        )
        # DocumentのエラーをPostに転送
        document.errors.each do |error|
          @post.errors.add(:base, "URL #{error.message}")
        end
      else
        document.save
        @post = @task.posts.build(
          user: current_user,
          postable_type: post_params[:postable_type],
          postable_attributes: { document_id: document.id }
        )
      end
    elsif post_params[:postable_type] == "TextPost"
      @post = @task.posts.build(
        user: current_user,
        postable_type: post_params[:postable_type],
        postable_attributes: post_params[:postable_attributes]
      )
    end

    if @post.errors.empty? && @post.save
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to @task, notice: "コメントが投稿されました。" }
      end
    else
      # 🎓 `app/views/tasks/show.html.erb`を再描画する際に必要な投稿一覧 @posts を取得。
      @posts = @task.posts.includes(:user, :postable).order(created_at: :asc)

      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html do
          render "tasks/show", status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task, notice: "投稿を削除しました。" }
    end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  end

  def set_post
    @post = @task.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:postable_type, postable_attributes: [ :body, :url ])
  end
end
