require 'rails_helper'

RSpec.describe 'TILs', type: :system do
  # 不正なパス名の定数
  EMPTY_PATHS = [ nil, "", " ", "\n", "\t" ].freeze
  INVALID_EXTENSION_PATHS = [ "category", "category/til", "category/til,md", "category/til.txt" ].freeze
  FORBIDDEN_CHAR_PATHS = [
    "category/a:b.md",
    "category/a*b.md",
    "category/a?b.md",
    "category/a|b.md",
    "category/a<b>.md",
    "category/a\"b.md"
  ].freeze
  INVALID_LOCATION_PATHS = [
    "../til.md",
    "category/../til.md",
    ".git/config/til.md",
    "/til.md",
    "category//til.md"
  ].freeze

  let(:user) { create(:user, github_token: 'test_token') }
  let(:done_task) { create(:done_task, user: user) }
  let(:mock_repo) { double('repo', full_name: 'test_user/test_repo', owner: double('owner', login: 'test_user'), name: 'test_repo') }
  let(:mock_client) { instance_double(Octokit::Client) }

  before do
    # Octokit::Clientのスタブ（メソッドの戻り値を設定）
    # 🎓 スタブについて
    # スタブはオブジェクトのメソッドの戻り値を設定することができる。
    # 指定方法: allow(object).to receive(method).and_return(value)
    allow(Octokit::Client).to receive(:new).and_return(mock_client)
    allow(mock_client).to receive(:repos).and_return([ mock_repo ])
    allow(mock_client).to receive(:create_contents).and_return(double('result', content: double('content', path: 'test.md')))

    sign_in user
    visit task_path(done_task)
  end

  describe '新しいmdファイル作成' do
    before do
      click_link '新しいmdファイルにTILを記録'

      # TIL作成画面へ遷移
      expect(page).to have_content('新しいmdファイルにTILを記録')

      # リポジトリを選択
      select 'test_user/test_repo', from: 'repo'

      # 選択されたリポジトリのリンク付きURLが表示される
      expect(page).to have_content('新しいmdファイルのパス名')
      expect(page).to have_link('test_user/test_repo', href: 'https://github.com/test_user/test_repo')
    end

    context '正常な入力の場合' do
      it 'コミットが成功しサクセスメッセージが表示される' do
        # GithubService#file_exists?をスタブしてfalseを返す（ファイルが存在しない）
        allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(false)

        fill_in '新しいmdファイルのパス名', with: 'category/today_i_learned.md'
        fill_in 'コミットメッセージ', with: 'Add TIL: test task'
        fill_in 'mdファイルの内容', with: '# Today I Learned\n\n今日学んだことを記録します。'

        click_button 'GitHubリポジトリに保存'

        # タスク詳細画面へリダイレクト
        expect(page).to have_current_path(task_path(done_task))

        # サクセスメッセージの表示
        expect(page).to have_content('新しいmdファイルにTILを記録しました')
      end
    end

    context '不正な入力の場合' do
      context 'パス名が空の場合' do
        EMPTY_PATHS.each do |empty_path|
          it "#{empty_path.inspect}の場合、エラーメッセージが表示される" do
            # GithubService#file_exists?をスタブしてfalseを返す（ファイルが存在しない）
            allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(false)

            fill_in '新しいmdファイルのパス名', with: empty_path.to_s
            fill_in 'コミットメッセージ', with: 'Test commit message'
            fill_in 'mdファイルの内容', with: 'Test content'

            click_button 'GitHubリポジトリに保存'

            # エラーメッセージの表示
            expect(page).to have_content('パス名 を入力してください')
          end
        end
      end

      context 'パス名の末尾が.mdではない場合' do
        INVALID_EXTENSION_PATHS.each do |invalid_path|
          it "#{invalid_path.inspect}の場合、エラーメッセージが表示される" do
            # GithubService#file_exists?をスタブしてfalseを返す（ファイルが存在しない）
            allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(false)

            fill_in '新しいmdファイルのパス名', with: invalid_path
            fill_in 'コミットメッセージ', with: 'Test commit message'
            fill_in 'mdファイルの内容', with: 'Test content'

            click_button 'GitHubリポジトリに保存'

            # エラーメッセージの表示
            expect(page).to have_content('パス名 は.mdで終わる必要があります')
          end
        end
      end

      context 'パス名が禁止文字を含む場合' do
        FORBIDDEN_CHAR_PATHS.each do |invalid_path|
          it "#{invalid_path.inspect}の場合、エラーメッセージが表示される" do
            # GithubService#file_exists?をスタブしてfalseを返す（ファイルが存在しない）
            allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(false)

            fill_in '新しいmdファイルのパス名', with: invalid_path
            fill_in 'コミットメッセージ', with: 'Test commit message'
            fill_in 'mdファイルの内容', with: 'Test content'

            click_button 'GitHubリポジトリに保存'

            # エラーメッセージの表示
            expect(page).to have_content('パス名 に使用できない文字が含まれています')
          end
        end
      end

      context 'パス名が不正な場合' do
        INVALID_LOCATION_PATHS.each do |invalid_path|
          it "#{invalid_path.inspect}の場合、エラーメッセージが表示される" do
            # GithubService#file_exists?をスタブしてfalseを返す（ファイルが存在しない）
            allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(false)

            fill_in '新しいmdファイルのパス名', with: invalid_path
            fill_in 'コミットメッセージ', with: 'Test commit message'
            fill_in 'mdファイルの内容', with: 'Test content'

            click_button 'GitHubリポジトリに保存'

            # エラーメッセージの表示
            expect(page).to have_content('パス名 は不正なパスです')
          end
        end
      end

      context 'パス名がすでに存在する場合' do
        it 'エラーメッセージが表示される' do
          # GithubService#file_exists?をスタブしてtrueを返す（ファイルが存在する）
          allow_any_instance_of(GithubService).to receive(:file_exists?).and_return(true)

          fill_in '新しいmdファイルのパス名', with: 'category/existing_file.md'
          fill_in 'コミットメッセージ', with: 'Test commit message'
          fill_in 'mdファイルの内容', with: 'Test content'

          click_button 'GitHubリポジトリに保存'

          # エラーメッセージの表示
          expect(page).to have_content('パス名 はすでに存在しています')
        end
      end
    end
  end
end
