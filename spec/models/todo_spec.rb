require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'バリデーション' do
    let(:task) { create(:task) }
    let(:todo) { build(:todo, task: task) }

    describe 'body' do
      context '存在性' do
        it 'bodyが存在する場合は有効' do
          todo.body = 'todo_body'
          expect(todo).to be_valid, 'bodyが存在する場合は有効である必要があります'
        end

        it 'bodyが空の場合は無効' do
          todo.body = ''
          expect(todo).not_to be_valid, 'bodyが空の場合は無効である必要があります'
          expect(todo.errors[:body]).to include('を入力してください')
        end

        it 'bodyがnilの場合は無効' do
          todo.body = nil
          expect(todo).not_to be_valid, 'bodyがnilの場合は無効である必要があります'
          expect(todo.errors[:body]).to include('を入力してください')
        end
      end

      context '文字数制限' do
        it '255文字以内の場合は有効' do
          todo.body = 'a' * 255
          expect(todo).to be_valid, 'bodyが255文字以内の場合は有効である必要があります'
        end

        it '256文字以上の場合は無効' do
          todo.body = 'a' * 256
          expect(todo).not_to be_valid, 'bodyが256文字以上の場合は無効である必要があります'
          expect(todo.errors[:body]).to include('は255文字以下で入力してください')
        end
      end
    end
  end

  describe 'アソシエーション' do
    describe 'belongs_to :task' do
      let(:task) { create(:task) }
      let(:todo) { build(:todo, task: task) }

      it 'taskにアクセスできる' do
        expect(todo.task).to eq task
      end

      it 'taskが存在しない場合は無効' do
        todo = build(:todo, task: nil)
        expect(todo).not_to be_valid, 'taskが存在しない場合は無効である必要があります'
      end

      it 'taskが存在する場合は有効' do
        expect(todo).to be_valid, 'taskが存在する場合は有効である必要があります'
      end
    end
  end

  describe '#done?' do
    let(:task) { create(:task) }
    let(:todo) { create(:todo, task: task) }

    it 'doneがtrueの場合はtrueを返す' do
      todo.update(done: true)
      expect(todo.done?).to be true
    end

    it 'doneがfalseの場合はfalseを返す' do
      todo.update(done: false)
      expect(todo.done?).to be false
    end
  end
end
