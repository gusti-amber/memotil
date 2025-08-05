require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーションチェック' do
    it '設定したすべてのバリデーションが機能しているか' do
      task = build(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'titleがない場合、バリデーションが機能し、invalidになる' do
      task_without_title = build(:task, title: nil)
      expect(task_without_title).to be_invalid
      expect(task_without_title.errors[:title]).to include("can't be blank")
    end

    it 'statusがない場合、バリデーションが機能し、invalidになる' do
      task_without_status = build(:task, status: nil)
      expect(task_without_status).to be_invalid
      expect(task_without_status.errors[:status]).to include("can't be blank")
    end

    it 'titleが1文字の場合、バリデーションが機能し、invalidになる' do
      task_with_short_title = build(:task, title: 'A')
      expect(task_with_short_title).to be_invalid
      expect(task_with_short_title.errors[:title]).to include('is too short (minimum is 2 characters)')
    end

    it 'titleが256文字の場合、バリデーションが機能し、invalidになる' do
      task_with_long_title = build(:task, title: 'A' * 256)
      expect(task_with_long_title).to be_invalid
      expect(task_with_long_title.errors[:title]).to include('is too long (maximum is 255 characters)')
    end
  end

  describe 'タグの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:tags) { create_list(:tag, 6) }

    it 'タグが5個以下の場合は有効' do
      task = build(:task, user: user, tag_ids: tags.first(5).map(&:id))
      expect(task).to be_valid
      expect(task.errors[:tag_ids]).to be_empty
    end

    it 'タグが6個の場合は無効' do
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_invalid
      expect(task.errors[:tag_ids]).to include('は最大5個まで選択できます')
    end

    it 'タグが選択されていない場合は有効' do
      task = build(:task, user: user, tag_ids: [])
      expect(task).to be_valid
      expect(task.errors[:tag_ids]).to be_empty
    end

    it 'タグが選択されていない場合（nil）は有効' do
      task = build(:task, user: user, tag_ids: nil)
      expect(task).to be_valid
      expect(task.errors[:tag_ids]).to be_empty
    end

    it 'タグが7個の場合は無効' do
      extra_tags = create_list(:tag, 1)
      all_tags = tags + extra_tags
      task = build(:task, user: user, tag_ids: all_tags.map(&:id))
      expect(task).to be_invalid
      expect(task.errors[:tag_ids]).to include('は最大5個まで選択できます')
    end
  end
end
