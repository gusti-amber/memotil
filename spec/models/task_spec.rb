require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーション' do
    it '設定したすべてのバリデーションが機能しているか' do
      task = build(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'titleがない場合、バリデーションが機能し、invalidになる' do
      task_without_title = build(:task, title: nil)
      expect(task_without_title).to be_invalid
      expect(task_without_title.errors[:title]).to include("を入力してください")
    end

    it 'statusがない場合、バリデーションが機能し、invalidになる' do
      task_without_status = build(:task, status: nil)
      expect(task_without_status).to be_invalid
    end

    it 'titleが1文字の場合、バリデーションが機能し、invalidになる' do
      task_with_short_title = build(:task, title: 'A')
      expect(task_with_short_title).to be_invalid
      expect(task_with_short_title.errors[:title]).to include('は2文字以上で入力してください')
    end

    it 'titleが256文字の場合、バリデーションが機能し、invalidになる' do
      task_with_long_title = build(:task, title: 'A' * 256)
      expect(task_with_long_title).to be_invalid
      expect(task_with_long_title.errors[:title]).to include('は255文字以下で入力してください')
    end
  end

  describe 'タグの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:max_tags) { 5 }
    let(:error_message) { 'は最大5個まで選択できます' }

    it 'タグが選択されていない場合（空配列）は有効' do
      task = build(:task, user: user, tag_ids: [])
      expect(task).to be_valid
    end

    it 'タグが選択されていない場合（nil）は有効' do
      task = build(:task, user: user, tag_ids: nil)
      expect(task).to be_valid
    end

    it 'タグが最大数以下の場合は有効' do
      tags = create_list(:tag, max_tags)
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_valid
    end

    it 'タグが最大数を超える場合は無効' do
      tags = create_list(:tag, max_tags + 1)
      task = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task).to be_invalid
      expect(task.errors[:tag_ids]).to include(error_message)
    end
  end
end
