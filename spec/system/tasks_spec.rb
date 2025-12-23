require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:other_user) { create(:user, email: 'other@example.com') }
  let(:other_user_task) { create(:task, user: other_user) }
  let(:max_tags) { 5 }
  let(:max_todos) { 5 }
  let!(:tags) { create_list(:tag, max_tags + 1) }

  # ステータス(Todo, Doing, Done)ごとのタスクを作成
  let(:todo_task) { create(:todo_task, user: user) }
  let(:doing_task) { create(:doing_task, user: user) }
  let!(:todo) { create(:todo, task: doing_task, body: 'test_todo') }
  let(:done_task) { create(:done_task, user: user) }

  describe '認証フィルター' do
    context '未ログインユーザーの場合' do
      it 'タスク一覧ページにアクセスするとログインページにリダイレクトされる' do
        visit tasks_path
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク作成ページにアクセスするとログインページにリダイレクトされる' do
        visit new_task_path
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク詳細ページにアクセスするとログインページにリダイレクトされる' do
        visit task_path(task)
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク編集ページにアクセスするとログインページにリダイレクトされる' do
        visit edit_task_path(task)
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end
    end
  end

  describe 'タスク新規作成' do
    before do
      sign_in user
      visit new_task_path
    end

    context '正常な入力の場合' do
      it 'タスクが新規作成される' do
        fill_in 'タイトル', with: 'test_task_with_tag'

        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click

        # 最初のタグを選択
        first('input[type="checkbox"]').check

        # ドロップダウンを閉じる
        # ⚠️ find('body').clickは正常に動作しない（セレクトボックスを閉じない）
        find('body').send_keys(:escape)

        click_button '作成'

        # タスク詳細画面へリダイレクト（パスは正規表現でチェック）
        expect(page).to have_current_path(%r{/tasks/\d+})

        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('タスクが作成されました')

        # コンテンツの表示
        expect(page).to have_content('test_task_with_tag')
        expect(page).to have_content(tags.first.name)
      end

      it '戻るボタンをクリックすると一覧ページに戻る' do
        click_link '戻る'
        expect(page).to have_content('タスク')
        expect(page).to have_link('作成')
      end
    end

    context 'バリデーションエラーが発生する場合' do
      it 'タイトルが空の場合、エラーメッセージが表示される' do
        fill_in 'タイトル', with: ''
        click_button '作成'

        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル を入力してください')
      end

      it 'タイトルが1文字の場合、エラーメッセージが表示される' do
        fill_in 'タイトル', with: 'a'
        click_button '作成'

        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル は2文字以上で入力してください')
      end

      it 'タイトルが256文字以上の場合、エラーメッセージが表示される' do
        fill_in 'タイトル', with: 'a' * 256
        click_button '作成'

        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル は255文字以下で入力してください')
      end

      it 'タグを最大数を超える数選択した場合、エラーメッセージが表示される' do
        fill_in 'タイトル', with: 'test_task_with_too_many_tags'

        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click

        # 最大数を超えるタグを選択
        (max_tags + 1).times do |i|
          all('input[type="checkbox"]')[i].check
        end

        # ドロップダウンを閉じる（ESCキーを押す）
        find('body').send_keys(:escape)

        click_button '作成'

        expect(current_path).to eq new_task_path
        expect(page).to have_content("タグ は最大#{max_tags}個まで選択できます")
      end
    end
  end

  describe 'タスク編集' do
    before do
      sign_in user
    end

    context '正常な入力の場合' do
      it 'タスクが正常に更新される' do
        visit edit_task_path(task)

        fill_in 'タイトル', with: 'updated_task_title'

        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click

        # 最初のタグを選択
        first('input[type="checkbox"]').check

        # ドロップダウンを閉じる
        find('body').send_keys(:escape)

        click_button '変更'

        expect(page).to have_content('updated_task_title')
        expect(page).to have_content(tags.first.name)
      end

      it '戻るボタンをクリックすると詳細ページに戻る' do
        visit edit_task_path(task)
        click_link '戻る'
        expect(page).to have_content(task.title)
      end
    end

    context 'バリデーションエラーが発生する場合' do
      it 'タイトルが空の場合、エラーメッセージが表示される' do
        visit edit_task_path(task)
        fill_in 'タイトル', with: ''
        click_button '変更'

        expect(current_path).to eq edit_task_path(task)
        expect(page).to have_content('タイトル を入力してください')
      end

      it 'タイトルが1文字の場合、エラーメッセージが表示される' do
        visit edit_task_path(task)
        fill_in 'タイトル', with: 'a'
        click_button '変更'

        expect(current_path).to eq edit_task_path(task)
        expect(page).to have_content('タイトル は2文字以上で入力してください')
      end

      it 'タイトルが256文字以上の場合、エラーメッセージが表示される' do
        visit edit_task_path(task)
        fill_in 'タイトル', with: 'a' * 256
        click_button '変更'

        expect(current_path).to eq edit_task_path(task)
        expect(page).to have_content('タイトル は255文字以下で入力してください')
      end

      it 'タグを最大数を超える数選択した場合、エラーメッセージが表示される' do
        visit edit_task_path(task)
        fill_in 'タイトル', with: 'updated_task_with_too_many_tags'

        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click

        # 最大数を超えるタグを選択
        (max_tags + 1).times do |i|
          all('input[type="checkbox"]')[i].check
        end

        # ドロップダウンを閉じる（ESCキーを押す）
        find('body').send_keys(:escape)

        click_button '変更'

        expect(current_path).to eq edit_task_path(task)
        expect(page).to have_content("タグ は最大#{max_tags}個まで選択できます")
      end
    end
    context '他のユーザーのタスクにアクセスしようとする場合' do
      skip '編集ページにアクセスするとタスク一覧ページにリダイレクトされる' do
        visit edit_task_path(other_user_task)
        expect(current_path).to eq tasks_path
        # expect(page).to have_content('アクセス権限がありません')
      end
    end
  end

  describe 'タスク詳細' do
    before do
      sign_in user
    end

    describe 'Todoタスク詳細' do
      before do
        visit task_path(todo_task)
      end

      context 'ToDoフォームの表示' do
        context 'ToDoフォームの「追加」ボタンをクリックする場合' do
          it 'ToDoフォームに新しいToDoフィールドが追加される' do
            # 初期状態では新規ToDoフィールドが0個であることを確認
            expect(all('[data-test-id="new-todo-field"]').count).to eq(0)

            # ToDoを追加
            click_button '追加'

            # 新しいToDoフィールドが1個追加されたことを確認
            expect(all('[data-test-id="new-todo-field"]').count).to eq(1)
          end
        end

        context '追加したToDoフィールドに入力し、「保存」ボタンをクリックする場合' do
          context '正常な入力の場合' do
            it 'ToDoが正常に保存される' do
              click_button '追加'

              # 最初のToDoフィールドに入力
              first('[data-test-id="new-todo-field"]').fill_in with: 'new_todo'

              click_button '保存'

              expect(page).to have_content('new_todo')
            end
          end

          context '追加したToDoフィールドを空のままにした場合' do
            it '更新は成功する' do
              # 更新前のToDo数を記録
              todo_count_before = task.todos.count

              # ToDoを追加
              click_button '追加'

              # ToDoフィールドを空のままにする
              first('[data-test-id="new-todo-field"]').fill_in with: ''

              click_button '保存'

              # 空のToDoは記録されないため、ToDo数は変わらない
              expect(task.reload.todos.count).to eq todo_count_before
            end
          end
        end

        context '既存のToDoフィールドに入力し、「保存」ボタンをクリックする場合' do
          let!(:todo) { create(:todo, task: todo_task, body: 'existing_todo') }
          context '正常な入力の場合' do
            it 'ToDoが正常に更新される' do
              # ToDoフォームへの切り替えボタンをクリック
              find('[data-test-id="show-todo-form-button"]').click

              # 既存のToDoフィールドに入力
              first('[data-test-id="existing-todo-field"]').fill_in with: 'update_todo'

              click_button '保存'

              expect(page).to have_content('update_todo')
            end
          end

          context 'バリデーションエラーが発生する場合' do
            it '既存のToDoフィールドを空にした場合、エラーメッセージが表示される' do
              # ToDoフォームへの切り替えボタンをクリック
              find('[data-test-id="show-todo-form-button"]').click

              # 既存のToDoフィールドを空にする
              first('[data-test-id="existing-todo-field"]').fill_in with: ''

              click_button '保存'

              expect(page).to have_content('ToDoの内容 を入力してください')
            end

            it '既存のToDoフィールドに256文字以上の値を入力した場合、エラーメッセージが表示される' do
              # ToDoフォームへの切り替えボタンをクリック
              find('[data-test-id="show-todo-form-button"]').click

              first('[data-test-id="existing-todo-field"]').fill_in with: 'a' * 256

              click_button '保存'

              expect(page).to have_content('ToDoの内容 は255文字以下で入力してください')
            end
          end
        end

        context '既存のToDoフィールドの削除ボタンをクリックした後、「保存」ボタンをクリックする場合' do
          let!(:todo) { create(:todo, task: todo_task, body: 'existing_todo') }
          it 'ToDoが正常に削除される' do
            # ToDoフォームへの切り替えボタンをクリック
            find('[data-test-id="show-todo-form-button"]').click

            accept_confirm do
              # 削除ボタンをクリック
              first('[data-test-id="delete-todo-button"]').click
            end

            click_button '保存'

            expect(page).not_to have_content('existing_todo')
          end
        end

        context '「追加」ボタンをクリックし、表示されるToDoフィールドが最大個数(5個)に達した場合' do
          it '追加ボタンが非表示になる' do
            # 追加ボタンが表示されていることを確認
            expect(page).to have_button('追加')

            # 最大個数のToDoを追加
            max_todos.times do |i|
              click_button '追加'
            end

            # 追加ボタンが非表示になっていることを確認
            expect(page).not_to have_button('追加')
          end
        end
      end
    end

    describe 'Doingタスク詳細' do
      before do
        visit task_path(doing_task)
      end

      context 'Todoのチェックボックスをクリックした場合' do
        it 'Todoの完了状態がトグルされる' do
          # 初期状態の確認
          expect(todo.reload.done?).to be false

          checkbox = find("[data-test-id='todo-checkbox']")

          # 完了にする
          checkbox.click
          expect(checkbox).to be_checked
          expect(todo.reload.done?).to be true

          # 未完了に戻す
          checkbox.click
          expect(checkbox).not_to be_checked
          expect(todo.reload.done?).to be false
        end
      end
    end

    describe 'Doneタスク詳細' do
      before do
        visit task_path(done_task)
      end
    end

    context '他のユーザーのタスクにアクセスしようとする場合' do
      skip '詳細ページにアクセスするとタスク一覧ページにリダイレクトされる' do
        visit task_path(other_user_task)
        expect(current_path).to eq tasks_path
        # expect(page).to have_content('アクセス権限がありません')
      end
    end
  end


  describe 'タスク削除' do
    before do
      sign_in user
      visit task_path(task)
    end

    context 'サイドバーから削除ボタンをクリックした場合' do
      it 'タスクは正常に削除される' do
        # 削除ボタンをクリック
        accept_confirm do
          click_link 'タスクを削除する'
        end

        # タスク一覧ページに遷移するまで待ってから確認
        expect(page).to have_current_path(tasks_path, ignore_query: true)

        # 削除完了を確認
        # expect(page).to have_content('タスクが削除されました')
        expect(Task.find_by(id: task.id)).to be_nil
      end
    end
  end

  describe 'タスクステータス変更' do
    before do
      sign_in user
    end

    context 'ステータスがTodoの場合' do
      let(:task) { create(:task, user: user, status: :todo) }

      it '「タスクに取り組む」ボタンをクリックすると、ステータスがDoingに変更される' do
        visit task_path(task)
        expect(page).to have_content('Todo')

        click_link 'タスクに取り組む'

        expect(page).to have_content('Doing')
      end
    end

    context 'ステータスがDoingの場合' do
      let(:task) { create(:task, user: user, status: :doing) }

      it '「タスクを完了する」ボタンをクリックすると、ステータスがDoneに変更される' do
        visit task_path(task)
        expect(page).to have_content('Doing')

        click_link 'タスクを完了する'

        expect(page).to have_content('Done')
      end
    end

    context 'ステータスがDoneの場合' do
      let(:task) { create(:task, user: user, status: :done) }

      it '「再びタスクに取り組む」ボタンをクリックすると、ステータスがDoingに変更される' do
        visit task_path(task)
        expect(page).to have_content('Done')

        click_link '再びタスクに取り組む'

        expect(page).to have_content('Doing')
      end
    end
  end

  describe "タスク一覧" do
    let!(:todo_task) { create(:task, user: user, status: 'todo', title: 'Todo Task') }
    let!(:doing_task) { create(:task, user: user, status: 'doing', title: 'Doing Task') }
    let!(:done_task) { create(:task, user: user, status: 'done', title: 'Done Task') }
    let!(:ruby_tag) { create(:tag, name: 'Ruby') }
    let!(:rails_tag) { create(:tag, name: 'Rails') }
    let!(:task_with_ruby_tag) { create(:task, user: user, status: 'todo', title: 'Ruby Task') }
    let!(:task_with_rails_tag) { create(:task, user: user, status: 'todo', title: 'Rails Task') }
    let!(:task_with_both_tags) { create(:task, user: user, status: 'todo', title: 'Both Tags Task') }
    let!(:task_without_tag) { create(:task, user: user, status: 'todo', title: 'No Tag Task') }

    before do
      task_with_ruby_tag.tags << ruby_tag
      task_with_rails_tag.tags << rails_tag
      task_with_both_tags.tags << ruby_tag
      task_with_both_tags.tags << rails_tag
      sign_in user
      visit tasks_path
    end

    context "ステータスフィルター" do
      context "セレクトボックスからtodoを選択した場合" do
        it "Todoステータスのタスクのみが表示される" do
          select 'Todo', from: 'q[status_eq]'
          expect(page).to have_content('Todo Task')
          expect(page).not_to have_content('Doing Task')
          expect(page).not_to have_content('Done Task')
        end
      end

      context "セレクトボックスからdoingを選択した場合" do
        it "Doingステータスのタスクのみが表示される" do
          select 'Doing', from: 'q[status_eq]'
          expect(page).to have_content('Doing Task')
          expect(page).not_to have_content('Todo Task')
          expect(page).not_to have_content('Done Task')
        end
      end

      context "セレクトボックスからdoneを選択した場合" do
        it "Doneステータスのタスクのみが表示される" do
          select 'Done', from: 'q[status_eq]'
          expect(page).to have_content('Done Task')
          expect(page).not_to have_content('Todo Task')
          expect(page).not_to have_content('Doing Task')
        end
      end

      context "セレクトボックスからすべてを選択した場合" do
        it "全タスクが表示される" do
          select 'すべての状態', from: 'q[status_eq]'
          expect(page).to have_content('Todo Task')
          expect(page).to have_content('Doing Task')
          expect(page).to have_content('Done Task')
        end
      end
    end

    context "タグフィルター" do
      context "セレクトボックスからRubyを選択した場合" do
        it "Rubyタグが付いたタスクのみが表示される" do
          select 'Ruby', from: 'q[tags_name_eq]'
          expect(page).to have_content('Ruby Task')
          expect(page).to have_content('Both Tags Task')
          expect(page).not_to have_content('Rails Task')
          expect(page).not_to have_content('No Tag Task')
        end
      end

      context "セレクトボックスからRailsを選択した場合" do
        it "Railsタグが付いたタスクのみが表示される" do
          select 'Rails', from: 'q[tags_name_eq]'
          expect(page).to have_content('Rails Task')
          expect(page).to have_content('Both Tags Task')
          expect(page).not_to have_content('Ruby Task')
          expect(page).not_to have_content('No Tag Task')
        end
      end

      context "セレクトボックスからすべてのタグを選択した場合" do
        it "全タスクが表示される" do
          select 'すべてのタグ', from: 'q[tags_name_eq]'
          expect(page).to have_content('Ruby Task')
          expect(page).to have_content('Rails Task')
          expect(page).to have_content('Both Tags Task')
          expect(page).to have_content('No Tag Task')
        end
      end
    end

    context "キーワード検索" do
      context "キーワードで検索した場合" do
        it "該当するタスクのみが表示される" do
          fill_in 'q[title_cont]', with: 'Todo'
          find('input[name="q[title_cont]"]').send_keys(:enter)
          expect(page).to have_content('Todo Task')
          expect(page).not_to have_content('Doing Task')
          expect(page).not_to have_content('Done Task')
        end
      end

      context "部分一致で検索した場合" do
        it "該当するタスクのみが表示される" do
          fill_in 'q[title_cont]', with: 'Tag'
          find('input[name="q[title_cont]"]').send_keys(:enter)
          expect(page).to have_content('Both Tags Task')
          expect(page).to have_content('No Tag Task')
          expect(page).not_to have_content('Ruby Task')
        end
      end

      context "存在しないキーワードで検索した場合" do
        it "タスクが表示されない" do
          fill_in 'q[title_cont]', with: 'NonExistent'
          find('input[name="q[title_cont]"]').send_keys(:enter)
          expect(page).not_to have_content('Todo Task')
          expect(page).not_to have_content('Doing Task')
          expect(page).not_to have_content('Done Task')
          expect(page).to have_content('タスクがありません')
        end
      end

      context "空のキーワードで検索した場合" do
        it "全タスクが表示される" do
          fill_in 'q[title_cont]', with: ''
          find('input[name="q[title_cont]"]').send_keys(:enter)
          expect(page).to have_content('Todo Task')
          expect(page).to have_content('Doing Task')
          expect(page).to have_content('Done Task')
        end
      end
    end

    context "オートコンプリート機能", js: true do
      let!(:ruby_task) { create(:task, user: user, title: "Ruby on Railsの学習") }
      let!(:ruby_method_task) { create(:task, user: user, title: "Rubyのメソッドを理解する") }
      let(:other_user) { create(:user, email: 'other@example.com') }
      let!(:other_user_task) { create(:task, user: other_user, title: "Other User Ruby Task") }

      context "2文字以上入力した場合" do
        it "候補がドロップダウンで表示される" do
          fill_in 'q[title_cont]', with: 'Ru'
          sleep 0.5

          expect(page).to have_css('ul[data-task-search-autocomplete-target="results"]:not(.hidden)')
          expect(page).to have_content('Ruby on Railsの学習')
          expect(page).to have_content('Rubyのメソッドを理解する')
        end
      end

      context "候補選択" do
        it "候補をクリックすると検索フォームが送信され、検索結果が表示される" do
          fill_in 'q[title_cont]', with: 'Ruby'
          sleep 0.5

          find('button', text: 'Ruby on Railsの学習').click

          expect(page).to have_content('Ruby on Railsの学習')
        end
      end

      context "セキュリティ" do
        it "他のユーザーのタスクは表示されない" do
          fill_in 'q[title_cont]', with: 'Ruby'
          sleep 0.5

          expect(page).not_to have_content('Other User Ruby Task')
        end
      end
    end
  end
end
