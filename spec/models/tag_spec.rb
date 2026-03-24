require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーション' do
    describe 'name' do
      it '空の場合は無効' do
        tag = build(:tag, name: '', user_id: nil)
        expect(tag).not_to be_valid
        expect(tag.errors[:name]).to include('を入力してください')
      end
    end

    describe 'システムタグ（user_id が nil）の名前の一意性' do
      it '大文字小文字を区別せず重複しない' do
        create(:tag, name: 'Ruby', user_id: nil)
        dup = build(:tag, name: 'ruby', user_id: nil)
        expect(dup).not_to be_valid
        expect(dup.errors[:name]).to include('はすでに登録済みです')
      end
    end

    describe 'ユーザー作成タグの名前の一意性' do
      it '同一ユーザー内で大文字小文字を区別せず重複しない' do
        user = create(:user)
        create(:tag, name: 'MyTag', user: user)
        dup = build(:tag, name: 'mytag', user: user)
        expect(dup).not_to be_valid
        expect(dup.errors[:name]).to include('はすでに登録済みです')
      end

      it '別ユーザーなら同じ名前でもよい' do
        u1 = create(:user)
        u2 = create(:user)
        create(:tag, name: 'Private', user: u1)
        other = build(:tag, name: 'Private', user: u2)
        expect(other).to be_valid
      end
    end
  end

  describe '.for_user' do
    it 'システムタグとそのユーザーのタグのみ返す' do
      user = create(:user)
      other = create(:user)
      system = create(:tag, name: 'system_only', user_id: nil)
      mine = create(:tag, name: 'mine', user: user)
      create(:tag, name: 'others', user: other)

      result = Tag.for_user(user)
      expect(result).to include(system, mine)
      expect(result).not_to include(Tag.find_by!(name: 'others'))
    end
  end
end
