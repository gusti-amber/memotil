class PostsController < ApplicationController
  def create
    @task = current_user.tasks.find(params[:task_id])
    
    # ネストした属性を使用して一度に作成
    @post = @task.posts.build(
      user: current_user,
      postable_type: post_params[:postable_type],
      postable_attributes: post_params[:postable_attributes]
    )

    if @post.save
      redirect_to @task, notice: "コメントが投稿されました。"
    else
      redirect_to @task, alert: "投稿の保存に失敗しました。"
    end
  end

  private

  def post_params
    params.require(:post).permit(:postable_type, postable_attributes: [:body])
  end
end
