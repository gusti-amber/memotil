class TilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  def new
    @client = GithubService.new(current_user.github_token)
    @repositories = @client.list_repositories

    @selected_repo = new_params[:selected_repo].presence
    @form = TilForm.new
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  end

  def create
    @client = GithubService.new(current_user.github_token)
    @form = TilForm.new(til_params, client: @client)
    if @form.valid?
      @client.create_contents(
        @form.repo,
        path: @form.path,
        message: @form.message,
        content: @form.body
      )
      redirect_to @task, notice: "新しいmdファイルにTILを記録しました"
    else
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  rescue Octokit::UnprocessableEntity => e
    redirect_to @task, alert: "ファイルの作成に失敗しました: #{e.message}"
  end

  private

  # tils#newで受け取るGETパラメータを許可
  def new_params
    params.permit(:selected_repo)
  end

  def til_params
    params.require(:til_form).permit(:path, :message, :body, :repo)
  end

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def ensure_done
    redirect_to @task, alert: "完了したタスクのみTILを反映できます" unless @task&.done?
  end
end
