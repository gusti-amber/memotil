class PostsController < ApplicationController
  def create
    @task = current_or_guest_user.tasks.find(params[:task_id])
    @post = @task.posts.build(user: current_or_guest_user)
    
    # TextPostを作成
    text_post = TextPost.new(post_params)
    
    if text_post.save
      @post.postable = text_post
      if @post.save
        redirect_to @task, notice: "コメントが投稿されました。" # ♻️ renderに変更できないか？
      else
        redirect_to @task, alert: "投稿の保存に失敗しました。"
      end
    else
      redirect_to @task, alert: "コメントの内容が無効です。"
    end
  end

  private

  def post_params
    params.require(:post).require(:postable_attributes).permit(:body)
  end
end 