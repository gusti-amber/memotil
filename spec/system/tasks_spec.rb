require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:other_user) { create(:user, email: 'other@example.com') }
  let(:other_user_task) { create(:task, user: other_user) }
  let(:max_tags) { 5 }
  let(:max_todos) { 3 }
  let!(:tags) { create_list(:tag, max_tags + 1) }
  let(:task_with_todo) { create(:task, user: user) }
  let!(:todo) { create(:todo, task: task_with_todo, body: 'test_todo') }

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

      it 'ToDoを追加してタスクが正常に更新される' do
        visit edit_task_path(task)

        # ToDoを追加
        click_button '追加'

        # 最初のToDoフィールドに入力
        first('input[placeholder="やることを入力してください"]').fill_in with: 'first_todo'

        click_button '変更'

        expect(page).to have_content(task.title)
        expect(page).to have_content('first_todo')
      end

      it 'ToDoを削除してタスクが正常に更新される' do
        visit edit_task_path(task_with_todo)

        # 最初のToDoの削除ボタンをクリック
        first('button[data-action="click->todo-form#remove"]').click

        # アラートが表示された場合はOKをクリック
        page.driver.browser.switch_to.alert.accept if page.driver.browser.switch_to.alert

        click_button '変更'

        expect(page).not_to have_content('test_todo')
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

      it '既存のToDoのbodyを空にした場合、エラーメッセージが表示される' do
        visit edit_task_path(task_with_todo)

        # 既存のToDoフィールドを空にする
        first('input[placeholder="やることを入力してください"]').fill_in with: ''

        click_button '変更'

        expect(current_path).to eq edit_task_path(task_with_todo)
        expect(page).to have_content('ToDoの内容 を入力してください')
      end

      it '新しく追加したToDoフィールドを空のままにした場合、更新は成功する' do
        # 更新前のToDo数を記録
        todo_count_before = task.todos.count

        visit edit_task_path(task)

        # ToDoを追加
        click_button '追加'

        # ToDoフィールドを空のままにする
        first('input[placeholder="やることを入力してください"]').fill_in with: ''

        click_button '変更'

        # 更新が成功し、タスク詳細ページに遷移する
        expect(page).to have_content(task.title)
        # 空のToDoは記録されないため、ToDo数は変わらない
        expect(task.reload.todos.count).to eq todo_count_before
      end

      it 'ToDoのbodyが256文字以上の場合、エラーメッセージが表示される' do
        visit edit_task_path(task)

        # ToDoを追加
        click_button '追加'

        # ToDoフィールドに256文字以上入力
        first('input[placeholder="やることを入力してください"]').fill_in with: 'a' * 256

        click_button '変更'

        expect(current_path).to eq edit_task_path(task)
        expect(page).to have_content('ToDoの内容 は255文字以下で入力してください')
      end
    end

    context 'UI制御' do
      it '追加ボタンを押し、ToDoフィールドが最大個数に達した場合、追加ボタンが非表示になる' do
        visit edit_task_path(task)

        # 追加ボタンが表示されていることを確認
        expect(page).to have_button('追加')

        # 最大個数のToDoを追加
        max_todos.times do |i|
          click_button '追加'
          all('input[placeholder="やることを入力してください"]')[i].fill_in with: "todo_#{i + 1}"
        end

        # 追加ボタンが非表示になっていることを確認
        expect(page).not_to have_button('追加')
      end

      it '初めからToDoが最大個数に達しているタスクでは、追加ボタンが非表示になっている' do
        # 初めから最大個数のToDoを持つタスクを作成
        task_with_max_todos = create(:task, user: user)
        create_list(:todo, max_todos, task: task_with_max_todos)

        visit edit_task_path(task_with_max_todos)

        # 追加ボタンが非表示になっていることを確認
        expect(page).not_to have_button('追加')
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
      visit task_path(task_with_todo)
    end

    context 'Todoのチェックボックスをクリックした場合' do
      it 'Todoの完了状態がトグルされる' do
        # 初期状態の確認
        expect(todo.reload.done?).to be false

        # チェックボックスをクリック
        find("input[type='checkbox']").click

        # JavaScriptの処理を待つ
        sleep 0.5

        # 完了状態がトグルされることを確認
        expect(todo.reload.done?).to be true

        # 再度クリックして未完了に戻す
        find("input[type='checkbox']").click

        # JavaScriptの処理を待つ
        sleep 0.5

        expect(todo.reload.done?).to be false
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
end
