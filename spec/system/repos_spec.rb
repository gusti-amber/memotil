require 'rails_helper'

RSpec.describe 'Repos', type: :system do
  # 禁止された文字を含むリポジトリ名の定数
  FORBIDDEN_CHAR_NAMES = [
    "my repo",        # スペースを含む
    "my@repo",        # @を含む
    "my#repo",        # #を含む
    "my$repo",        # $を含む
    "my%repo",        # %を含む
    "my^repo",        # ^を含む
    "my&repo",        # &を含む
    "my*repo",        # *を含む
    "my(repo)",       # ()を含む
    "my+repo",        # +を含む
    "my=repo",        # =を含む
    "my[repo]",       # []を含む
    "my{repo}",       # {}を含む
    "my|repo",        # |を含む
    "my\\repo",       # \を含む
    "my:repo",        # :を含む
    "my;repo",        # ;を含む
    "my\"repo",       # "を含む
    "my'repo",        # 'を含む
    "my<repo>",       # <>を含む
    "my,repo",        # ,を含む
    "my?repo",        # ?を含む
    "my/repo",        # /を含む
    "my~repo",        # ~を含む
    "my`repo",        # `を含む
    "my!repo",        # !を含む
    "リポジトリ",      # 日本語を含む
  ].freeze

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
        # GithubService#repository_exists?をスタブしてfalseを返す（リポジトリが存在しない）
        allow_any_instance_of(GithubService).to receive(:repository_exists?).and_return(false)

        fill_in 'name', with: 'til'
        fill_in 'description', with: '今日学んだことを記録するリポジトリ'

        click_button 'GitHubリポジトリを作成'

        # タスク詳細画面へリダイレクト
        expect(page).to have_current_path(task_path(done_task))

        # サクセスメッセージの表示
        expect(page).to have_content('新しいリポジトリを作成しました')
      end
    end

    context '不正なリポジトリ名を入力した場合' do
      context 'リポジトリ名が空の場合' do
        it 'リポジトリ作成が失敗しエラーメッセージが表示される' do
          fill_in 'name', with: ''
          fill_in 'description', with: '今日学んだことを記録するリポジトリ'

          click_button 'GitHubリポジトリを作成'

          # エラーメッセージの表示
          expect(page).to have_content('リポジトリ名を入力してください')
        end
      end

      context 'リポジトリ名が正しい形式でない場合' do
        FORBIDDEN_CHAR_NAMES.each do |invalid_name|
          it "#{invalid_name.inspect}の場合、エラーメッセージが表示される" do
            fill_in 'name', with: invalid_name
            fill_in 'description', with: '今日学んだことを記録するリポジトリ'

            click_button 'GitHubリポジトリを作成'

            # エラーメッセージの表示
            expect(page).to have_content('リポジトリ名は英数字と一部の記号( ., -, _ )のみ使用できます')
          end
        end
      end

      context 'リポジトリ名がすでに存在する場合' do
        it 'リポジトリ作成が失敗しエラーメッセージが表示される' do
          # GithubService#repository_exists?をスタブしてtrueを返す（リポジトリが存在する）
          allow_any_instance_of(GithubService).to receive(:repository_exists?).and_return(true)

          fill_in 'name', with: 'existing_repo'
          fill_in 'description', with: '今日学んだことを記録するリポジトリ'

          click_button 'GitHubリポジトリを作成'

          # エラーメッセージの表示
          expect(page).to have_content('指定したリポジトリ名はすでに存在しています')
        end
      end
    end
  end
end
