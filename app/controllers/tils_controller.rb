class TilsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  # 将来的な実装: README.md編集機能
  # def edit
  #   @client = GithubService.new(current_user.github_token)
  #   @repositories = @client.list_repositories
  #
  #   @selected_repo = params[:repo].presence
  #   if @selected_repo
  #     readme = @client.fetch_readme(@selected_repo)
  #     @readme_sha = readme[:sha]
  #     @readme_body = readme[:body]
  #   end
  # rescue Octokit::Unauthorized
  #   redirect_to @task, alert: "GitHub連携が必要です"
  # end
  #
  # def update
  #   # ✨ リポジトリ内にREADME.mdがない場合の処理も今後実装予定
  #   client = GithubService.new(current_user.github_token)
  #   client.update_readme(params[:repo], message: params[:message], new_body: params[:body], sha: params[:sha])
  #   redirect_to @task, notice: "GitHubリポジトリにTILを保存しました"
  # end

  def new
    @client = GithubService.new(current_user.github_token)
    @repositories = @client.list_repositories

    @selected_repo = params[:repo].presence
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
