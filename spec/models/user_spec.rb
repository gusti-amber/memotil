require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    let(:user) { build(:user) }

    describe 'name' do
      context '存在性' do
        it 'nameが存在する場合は有効' do
          user.name = 'userテスト'
          expect(user).to be_valid
        end

        it 'nameが空の場合は無効' do
          user.name = ''
          expect(user).not_to be_valid
          expect(user.errors[:name]).to include('を入力してください')
        end

        it 'nameがnilの場合は無効' do
          user.name = nil
          expect(user).not_to be_valid
          expect(user.errors[:name]).to include('を入力してください')
        end
      end

      context '文字数制限' do
        it '2文字以上20文字以内の場合は有効' do
          user.name = 'テスト'
          expect(user).to be_valid
        end

        it '1文字の場合は無効' do
          user.name = 'A'
          expect(user).not_to be_valid
          expect(user.errors[:name]).to include('は2文字以上で入力してください')
        end

        it '21文字以上の場合は無効' do
          user.name = 'A' * 21
          expect(user).not_to be_valid
          expect(user.errors[:name]).to include('は20文字以下で入力してください')
        end
      end
    end

    describe 'password' do
      context '文字数制限' do
        it '8文字以上128文字以内の場合は有効' do
          user.password = '12345678'
          user.password_confirmation = '12345678'
          expect(user).to be_valid
        end

        it '7文字以下の場合は無効' do
          user.password = '1234567'
          user.password_confirmation = '1234567'
          expect(user).not_to be_valid
          expect(user.errors[:password]).to include('は8文字以上で入力してください')
        end

        it '129文字以上の場合は無効' do
          user.password = 'a' * 129
          user.password_confirmation = 'a' * 129
          expect(user).not_to be_valid
          expect(user.errors[:password]).to include('は128文字以下で入力してください')
        end
      end
    end

    describe 'email' do
      context '存在性' do
        it 'emailが空の場合は無効' do
          user.email = ''
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include('を入力してください')
        end

        it 'emailがnilの場合は無効' do
          user.email = nil
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include('を入力してください')
        end
      end

      context '形式' do
        it '有効なemail形式の場合は有効' do
          user.email = 'test@example.com'
          expect(user).to be_valid
        end

        it '無効なemail形式の場合は無効' do
          user.email = 'invalid-email'
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include('は無効な値です')
        end
      end

      context '一意性' do
        let!(:existing_user) { create(:user, email: 'test@example.com') }

        it '同じemailでユーザーを作成できない' do
          new_user = build(:user, email: 'test@example.com')
          expect(new_user).not_to be_valid
          expect(new_user.errors[:email]).to include('はすでに存在しています')
        end
      end
    end
  end

  describe 'アソシエーション' do
    describe 'has_many :tasks' do
      let(:user) { create(:user) }
      let(:task_count) { 3 }
      let!(:tasks) { create_list(:task, task_count, user: user) }

      it 'tasksにアクセスできる' do
        expect(user.tasks).to match_array(tasks)
      end

      it 'userが削除されると、関連するtasksも削除される' do
        expect { user.destroy }.to change(Task, :count).by(-task_count)
      end
    end

    describe 'has_many :posts' do
      let(:user) { create(:user) }
      let(:post_count) { 2 }
      let!(:posts) { create_list(:post, post_count, user: user) }

      it 'postsにアクセスできる' do
        expect(user.posts).to match_array(posts)
      end

      it 'userが削除されると、関連するpostsも削除される' do
        expect { user.destroy }.to change(Post, :count).by(-post_count)
      end
    end
  end
end
