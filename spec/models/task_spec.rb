require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーション' do
    let(:user) { create(:user) }
    let(:task) { build(:task, user: user) }

    describe 'title' do
      context '存在性' do
        it 'titleが存在する場合は有効' do
          task.title = 'task_title'
          expect(task).to be_valid, 'titleが存在する場合は有効である必要があります'
        end

        it 'titleが空の場合は無効' do
          task.title = ''
          expect(task).not_to be_valid, 'titleが空の場合は無効である必要があります'
          expect(task.errors[:title]).to include('を入力してください')
        end

        it 'titleがnilの場合は無効' do
          task.title = nil
          expect(task).not_to be_valid, 'titleがnilの場合は無効である必要があります'
          expect(task.errors[:title]).to include('を入力してください')
        end
      end

      context '文字数制限' do
        it '2文字以上255文字以内の場合は有効' do
          task.title = 'task_title'
          expect(task).to be_valid, 'titleが2文字以上255文字以内の場合は有効である必要があります'
        end

        it '1文字の場合は無効' do
          task.title = 'a'
          expect(task).not_to be_valid, 'titleが1文字の場合は無効である必要があります'
          expect(task.errors[:title]).to include('は2文字以上で入力してください')
        end

        it '256文字以上の場合は無効' do
          task.title = 'a' * 256
          expect(task).not_to be_valid, 'titleが256文字以上の場合は無効である必要があります'
          expect(task.errors[:title]).to include('は255文字以下で入力してください')
        end
      end
    end

    describe 'status' do
      it 'statusが存在する場合は有効' do
        task.status = 'todo'
        expect(task).to be_valid, 'statusが存在する場合は有効である必要があります'
      end

      it 'statusがnilの場合は無効' do
        task.status = nil
        expect(task).not_to be_valid, 'statusがnilの場合は無効である必要があります'
      end
    end
  end

  describe 'Todoの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:max_todos) { 3 }
    let(:error_message) { 'は最大3個まで作成できます' }

    it 'Todoが存在しない場合は有効' do
      task = build(:task, user: user)
      expect(task).to be_valid, 'Todoが存在しない場合は有効である必要があります'
    end

    it 'Todoが最大数以下の場合は有効' do
      task = build(:task, user: user)
      create_list(:todo, max_todos, task: task)
      expect(task).to be_valid, 'Todoが最大数以下の場合は有効である必要があります'
    end

    it 'Todoが最大数を超える場合は無効' do
      task = build(:task, user: user)
      create_list(:todo, max_todos + 1, task: task)
      expect(task).not_to be_valid, 'Todoが最大数を超える場合は無効である必要があります'
      expect(task.errors[:todos]).to include(error_message)
    end
  end

  describe 'タグの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:max_tags) { 5 }
    let(:error_message) { 'は最大5個まで選択できます' }

    it 'タグが選択されていない場合（空配列）は有効' do
      task = build(:task, user: user, tag_ids: [])
      expect(task).to be_valid, 'タグが選択されていない場合（空配列）は有効である必要があります'
    end

    it 'タグが選択されていない場合（nil）は有効' do
      task = build(:task, user: user, tag_ids: nil)
      expect(task).to be_valid, 'タグが選択されていない場合（nil）は有効である必要があります'
    end

    it 'タグが最大数以下の場合は有効' do
      tags = create_list(:tag, max_tags)
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_valid, 'タグが最大数以下の場合は有効である必要があります'
    end

    it 'タグが最大数を超える場合は無効' do
      tags = create_list(:tag, max_tags + 1)
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_invalid, 'タグが最大数を超える場合は無効である必要があります'
      expect(task.errors[:tag_ids]).to include(error_message)
    end
  end
end
