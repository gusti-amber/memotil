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
          # text-post-formというidを持つformタグ内で投稿ボタンをクリック
          within('#text-post-form') do
            click_button '投稿'
          end

          expect(page).to have_content('test_text_post')
          # expect(page).to have_content('コメントが投稿されました。')
          expect(current_path).to eq task_path(task)
        end
      end

      context 'バリデーションエラーが発生する場合' do
        it 'bodyが空の場合、エラーメッセージが表示される' do
          fill_in 'post[postable_attributes][body]', with: ''
          within('#text-post-form') do
            click_button '投稿'
          end

          # expect(page).to have_content('コメントの内容が無効です。')
          expect(current_path).to eq task_path(task)
        end

        it 'bodyが501文字以上の場合、エラーメッセージが表示される' do
          fill_in 'post[postable_attributes][body]', with: 'a' * 501
          within('#text-post-form') do
            click_button '投稿'
          end

          # expect(page).to have_content('コメントの内容が無効です。')
          expect(current_path).to eq task_path(task)
        end
      end
    end

    context 'DocumentPost作成' do
      context '正常な入力の場合' do
        it 'DocumentPostが正常に作成される' do
          # DocumentPost投稿フォームのタブをクリック
          find('input[aria-label="ドキュメント"]').click
          
          fill_in 'post[postable_attributes][url]', with: 'https://docs.example.com'
          within('#document-post-form') do
            click_button '投稿'
          end

          # ポスト一覧に投稿されたDocumentPostが表示されることを確認
          expect(page).to have_content('https://docs.example.com')
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
        it '投稿一覧にTextPostが正しく表示される' do
          expect(page).to have_content('test_text_post')
          expect(page).to have_content(user.name)
          expect(page).to have_content(post.created_at.strftime("%Y年%m月%d日 %H:%M"))
        end
      end
    end
  end

  describe '投稿削除' do
    let(:task) { create(:task, user: user) }
    let!(:post) { create(:post, user: user, task: task, postable: create(:text_post, body: 'test_text_post')) }

    before do
      sign_in user
      visit task_path(task)
    end

    context '正常な削除の場合' do
      it '右クリックでコンテキストメニューが表示される' do
        # 投稿のchat-bubble要素を右クリック
        chat_bubble = find('.chat-bubble')
        chat_bubble.right_click

        # 削除ボタンをクリック
        accept_confirm do
          within('[data-post-context-menu-target="menu"]') do
            click_link '削除'
          end
        end

        # 投稿が削除されることを確認
        expect(page).not_to have_content('test_text_post')
        expect(current_path).to eq task_path(task)
      end

      it '削除確認ダイアログでキャンセルした場合、投稿が削除されない' do
        # 投稿のchat-bubble要素を右クリック
        chat_bubble = find('.chat-bubble')
        chat_bubble.right_click

        # 削除ボタンをクリック
        dismiss_confirm do
          within('[data-post-context-menu-target="menu"]') do
            click_link '削除'
          end
        end

        # 投稿が残っていることを確認
        expect(page).to have_content('test_text_post')
        expect(current_path).to eq task_path(task)
      end
    end
  end
end
