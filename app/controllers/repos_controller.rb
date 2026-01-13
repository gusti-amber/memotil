class ReposController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :ensure_done

  def new
    @client = GithubService.new(current_user.github_token)
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  end

  def create
    @validation_name_error = validate_name(params[:name])
    if @validation_name_error
      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
      return
    end

    client = GithubService.new(current_user.github_token)
    client.create_repository(
      name: params[:name],
      description: params[:description],
      private: params[:private],
      auto_init: params[:auto_init] == "true" # Boolean型に変換
    )
    redirect_to @task, notice: "新しいリポジトリを作成しました"
  rescue Octokit::Unauthorized
    redirect_to @task, alert: "GitHub連携が必要です"
  rescue Octokit::UnprocessableEntity => e
    redirect_to new_task_repo_path(@task), alert: "リポジトリの作成に失敗しました: #{e.message}"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "アクセス権限がありません"
  end

  def ensure_done
    redirect_to @task, alert: "完了したタスクのみリポジトリを作成できます" unless @task&.done?
  end

  def validate_name(name)
    return "リポジトリ名を入力してください" if name.blank? || name.strip.empty?
    return "リポジトリ名は英数字と一部の記号( ., -, _ )のみ使用できます" unless valid_format?(name)

    nil
  end

  def valid_format?(name)
    name.match?(/\A[a-zA-Z0-9._-]+\z/)
  end
end
