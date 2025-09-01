require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let(:user) { create(:user) }

  describe '投稿作成' do
    let(:task) { create(:task, user: user) }

    before do
      sign_in user
      visit task_path(task)
    end

    context 'TextPost作成' do
      context '正常な入力の場合' do
        it 'TextPostが正常に作成される' do
          fill_in 'post[postable_attributes][body]', with: 'test_text_post'
          click_button '投稿'

          expect(page).to have_content('test_text_post')
          # expect(page).to have_content('コメントが投稿されました。')
          expect(current_path).to eq task_path(task)
        end
      end

      context 'バリデーションエラーが発生する場合' do
        it 'bodyが空の場合、エラーメッセージが表示される' do
          fill_in 'post[postable_attributes][body]', with: ''
          click_button '投稿'

          # expect(page).to have_content('コメントの内容が無効です。')
          expect(current_path).to eq task_path(task)
        end

        it 'bodyが501文字以上の場合、エラーメッセージが表示される' do
          fill_in 'post[postable_attributes][body]', with: 'a' * 501
          click_button '投稿'

          # expect(page).to have_content('コメントの内容が無効です。')
          expect(current_path).to eq task_path(task)
        end
      end
    end
  end

  describe '投稿表示' do
    context '投稿が存在する場合' do
      let(:task) { create(:task, user: user) }
      let!(:post) { create(:post, user: user, task: task, postable: create(:text_post, body: 'test_text_post')) }

      before do
        sign_in user
        visit task_path(task)
      end

      context 'TextPostが存在する場合' do
        it 'TextPost一覧が正しく表示される' do
          expect(page).to have_content('test_text_post')
          expect(page).to have_content(user.name)
          expect(page).to have_content(post.created_at.strftime("%Y年%m月%d日 %H:%M"))
        end
      end
    end

    context '投稿が存在しない場合' do
      let(:empty_task) { create(:task, user: user) }

      before do
        sign_in user
        visit task_path(empty_task)
      end

      it '「まだ投稿はありません」メッセージが表示される' do
        expect(page).to have_content('まだ投稿はありません')
      end
    end
  end
end
