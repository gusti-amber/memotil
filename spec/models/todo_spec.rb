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

  describe 'アソシエーション' do
    describe 'belongs_to :task' do
      it 'taskが存在しない場合は無効' do
        todo = build(:todo, task: nil)
        expect(todo).not_to be_valid
      end

      it 'taskが存在する場合は有効' do
        task = create(:task)
        todo = build(:todo, task: task)
        expect(todo).to be_valid
      end
    end
  end

  describe '依存関係' do
    describe 'Task削除時の依存関係' do
      let(:task) { create(:task) }
      
      context '1つのTodoが存在する場合' do
        let!(:todo) { create(:todo, task: task) }
        
        it 'Taskが削除されると、関連するTodoも削除される' do
          expect { task.destroy }.to change(Todo, :count).by(-1)
        end
        
        it 'Taskが削除されると、Todoが存在しなくなる' do
          task.destroy
          expect(Todo.exists?(todo.id)).to be false
        end
      end
      
      context '最大3つのTodoが存在する場合' do
        let!(:todos) { create_list(:todo, 3, task: task) }
        
        it 'Taskが削除されると、すべてのTodoが削除される' do
          expect { task.destroy }.to change(Todo, :count).by(-3)
        end
        
        it 'Taskが削除されると、すべてのTodoが存在しなくなる' do
          todo_ids = todos.map(&:id)
          task.destroy
          expect(Todo.where(id: todo_ids)).to be_empty
        end
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
