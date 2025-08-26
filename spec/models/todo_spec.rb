require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'バリデーション' do
    let(:task) { create(:task) }
    let(:todo) { build(:todo, task: task) }

    describe 'body' do
      context '存在性' do
        it 'bodyが存在する場合は有効' do
          todo.body = 'todoテスト'
          expect(todo).to be_valid
        end

        it 'bodyが空の場合は無効' do
          todo.body = ''
          expect(todo).not_to be_valid
          expect(todo.errors[:body]).to include('を入力してください')
        end

        it 'bodyがnilの場合は無効' do
          todo.body = nil
          expect(todo).not_to be_valid
          expect(todo.errors[:body]).to include('を入力してください')
        end
      end

      context '文字数制限' do
        it '255文字以内の場合は有効' do
          todo.body = 'a' * 255
          expect(todo).to be_valid
        end

        it '256文字以上の場合は無効' do
          todo.body = 'a' * 256
          expect(todo).not_to be_valid
          expect(todo.errors[:body]).to include('は255文字以下で入力してください')
        end
      end
    end
  end
end
