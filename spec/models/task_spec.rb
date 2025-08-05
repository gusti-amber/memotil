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
      expect(task_without_title.errors[:title]).to include("タイトルを入力してください")
    end

    it 'statusがない場合、バリデーションが機能し、invalidになる' do
      task_without_status = build(:task, status: nil)
      expect(task_without_status).to be_invalid
      expect(task_without_status.errors[:status]).to include("ステータスを選択してください")
    end

    it 'titleが1文字の場合、バリデーションが機能し、invalidになる' do
      task_with_short_title = build(:task, title: 'A')
      expect(task_with_short_title).to be_invalid
      expect(task_with_short_title.errors[:title]).to include('タイトルは2文字以上で入力してください')
    end

    it 'titleが256文字の場合、バリデーションが機能し、invalidになる' do
      task_with_long_title = build(:task, title: 'A' * 256)
      expect(task_with_long_title).to be_invalid
      expect(task_with_long_title.errors[:title]).to include('タイトルは255文字以下で入力してください')
    end
  end

  describe 'タグの個数制限バリデーション' do
    let(:user) { create(:user) }
    let(:tags) { create_list(:tag, 6) }

    it 'タグが5個以下の場合、validになる' do
      task_with_five_tags = build(:task, user: user, tag_ids: tags.first(5).map(&:id))
      expect(task_with_five_tags).to be_valid
      expect(task_with_five_tags.errors[:tag_ids]).to be_empty
    end

    it 'タグが6個の場合、invalidになる' do
      task_with_six_tags = build(:task, user: user, tag_ids: tags.map(&:id))
      expect(task_with_six_tags).to be_invalid
      expect(task_with_six_tags.errors[:tag_ids]).to include('は最大5個まで選択できます')
    end

    it 'タグが選択されていない場合、validになる' do
      task_without_tags = build(:task, user: user, tag_ids: [])
      expect(task_without_tags).to be_valid
      expect(task_without_tags.errors[:tag_ids]).to be_empty
    end

    it 'タグが選択されていない場合（nil）、validになる' do
      task_with_nil_tags = build(:task, user: user, tag_ids: nil)
      expect(task_with_nil_tags).to be_valid
      expect(task_with_nil_tags.errors[:tag_ids]).to be_empty
    end

    it 'タグが7個の場合、invalidになる' do
      extra_tags = create_list(:tag, 1)
      all_tags = tags + extra_tags
      task_with_seven_tags = build(:task, user: user, tag_ids: all_tags.map(&:id))
      expect(task_with_seven_tags).to be_invalid
      expect(task_with_seven_tags.errors[:tag_ids]).to include('は最大5個まで選択できます')
    end
  end
end
