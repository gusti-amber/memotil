class PostsController < ApplicationController
  before_action :set_task
  before_action :set_post, only: [ :destroy ]

  def create
    # ネストした属性を使用して一度に作成
    if post_params[:postable_type] == "DocumentPost"
      document_url = post_params[:postable_attributes][:url]
      document = Document.find_or_create_by(url: document_url)
      @post = @task.posts.build(
        user: current_user,
        postable_type: post_params[:postable_type],
        postable_attributes: { document_id: document.id }
      )
    elsif post_params[:postable_type] == "TextPost"
      @post = @task.posts.build(
        user: current_user,
        postable_type: post_params[:postable_type],
        postable_attributes: post_params[:postable_attributes]
      )
    end

    if @post.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @task, notice: "コメントが投稿されました。" }
      end
    else
      # ⚠️ この実装では、501文字以上の文章を投稿しようとした場合、投稿フォーム上の文章が消えてしまう。
      # また、投稿フォームパーシャル内にエラーメッセージを実装したい。
      respond_to do |format|
        format.html { redirect_to @task, alert: "投稿の保存に失敗しました。" }
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
