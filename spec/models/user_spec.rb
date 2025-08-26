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
  end
end
