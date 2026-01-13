require 'rails_helper'

RSpec.describe 'Repos', type: :system do
  let(:user) { create(:user, github_token: 'test_token') }
  let(:done_task) { create(:done_task, user: user) }
  let(:mock_account) { double('account', login: 'test_account') }
  let(:mock_repository) { double('repository', full_name: 'test_account/til', name: 'til') }
  let(:mock_client) { instance_double(Octokit::Client) }

  before do
    # Octokit::Clientのスタブ（メソッドの戻り値を設定）
    # 🎓 スタブについて
    # スタブはオブジェクトのメソッドの戻り値を設定することができる。
    # 指定方法: allow(object).to receive(method).and_return(value)
    allow(Octokit::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:user).and_return(mock_account)
    allow(mock_client).to receive(:create_repository).and_return(mock_repository)

    sign_in user
    visit task_path(done_task)
  end

  describe '新規リポジトリ作成' do
    before do
      click_link '新しいリポジトリを作成'

      # リポジトリ作成画面へ遷移
      expect(page).to have_content('新しいリポジトリを作成')
    end

    context '正しいリポジトリ名を入力した場合' do
      it 'リポジトリ作成が成功しサクセスメッセージが表示される' do
        fill_in 'name', with: 'til'
        fill_in 'description', with: '今日学んだことを記録するリポジトリ'

        click_button 'GitHubリポジトリを作成'

        # タスク詳細画面へリダイレクト
        expect(page).to have_current_path(task_path(done_task))

        # サクセスメッセージの表示
        expect(page).to have_content('新しいリポジトリを作成しました')
      end
    end
  end
end
