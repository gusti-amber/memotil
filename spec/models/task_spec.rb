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

    it 'Todoが存在しない場合は有効' do
      task = build(:task, user: user)
      expect(task).to be_valid, 'Todoが存在しない場合は有効である必要があります'
    end

    it 'Todoが最大数以下の場合は有効' do
      task = build(:task, user: user)
      create_list(:todo, max_todos, task: task)
      expect(task).to be_valid, "Todoが最大数（#{max_todos}個）以下の場合は有効である必要があります"
    end

    it 'Todoが最大数を超える場合は無効' do
      task = build(:task, user: user)
      create_list(:todo, max_todos + 1, task: task)
      expect(task).not_to be_valid, "Todoが最大数（#{max_todos}個）を超える場合は無効である必要があります"
      expect(task.errors[:todos]).to include("は最大#{max_todos}個まで作成できます")
    end
  end

  describe 'タグの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:max_tags) { 5 }

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
      expect(task).to be_valid, "タグが最大数（#{max_tags}個）以下の場合は有効である必要があります"
    end

    it 'タグが最大数を超える場合は無効' do
      tags = create_list(:tag, max_tags + 1)
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_invalid, "タグが最大数（#{max_tags}個）を超える場合は無効である必要があります"
      expect(task.errors[:tag_ids]).to include("は最大#{max_tags}個まで選択できます")
    end
  end

  describe 'アソシエーション' do
    describe 'belongs_to :user' do
      let(:user) { create(:user) }
      let(:task) { build(:task, user: user) }

      it 'userにアクセスできる' do
        expect(task.user).to eq user
      end

      it 'userが存在しない場合は無効' do
        task = build(:task, user: nil)
        expect(task).not_to be_valid, 'userが存在しない場合は無効である必要があります'
      end

      it 'userが存在する場合は有効' do
        expect(task).to be_valid, 'userが存在する場合は有効である必要があります'
      end
    end

    describe 'has_many :todos' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:todo_count) { 2 }
      let!(:todos) { create_list(:todo, todo_count, task: task) }

      it 'todosにアクセスできる' do
        expect(task.todos).to match_array(todos)
      end

      it 'taskが削除されると、関連するtodosも削除される' do
        expect { task.destroy }.to change(Todo, :count).by(-todo_count), 'taskが削除されると、関連するtodosも削除される必要があります'
      end
    end

    describe 'has_many :posts' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:post_count) { 2 }
      let!(:posts) { create_list(:post, post_count, task: task) }

      it 'postsにアクセスできる' do
        expect(task.posts).to match_array(posts)
      end

      it 'taskが削除されると、関連するpostsも削除される' do
        expect { task.destroy }.to change(Post, :count).by(-post_count), 'taskが削除されると、関連するpostsも削除される必要があります'
      end
    end

    describe 'has_many :tasktags' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:tasktag_count) { 2 }
      let!(:tasktags) { create_list(:tasktag, tasktag_count, task: task) }

      it 'tasktagsにアクセスできる' do
        expect(task.tasktags).to match_array(tasktags)
      end

      it 'taskが削除されると、関連するtasktagsも削除される' do
        expect { task.destroy }.to change(Tasktag, :count).by(-tasktag_count), 'taskが削除されると、関連するtasktagsも削除される必要があります'
      end
    end

    describe 'has_many :tags, through: :tasktags' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:tags) { create_list(:tag, 2) }
      let!(:tasktags) do
        tags.map { |tag| create(:tasktag, task: task, tag: tag) }
      end

      it 'tagsにアクセスできる' do
        expect(task.tags).to match_array(tags)
      end
    end
  end
end
