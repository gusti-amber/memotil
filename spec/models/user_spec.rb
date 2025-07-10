require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it '設定したすべてのバリデーションが機能しているか' do
      user = build(:user)
      expect(user).to be_valid
      expect(user.errors).to be_empty
    end

    it 'nameがない場合、バリデーションが機能し、invalidになる' do
      user = build(:user, name: nil)
      expect(user).to be_invalid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'nameが1文字の場合、バリデーションが機能し、invalidになる' do
      user = build(:user, name: 'A')
      expect(user).to be_invalid
      expect(user.errors[:name]).to include('is too short (minimum is 2 characters)')
    end

    it 'nameが51文字の場合、バリデーションが機能し、invalidになる' do
      user = build(:user, name: 'A' * 51)
      expect(user).to be_invalid
      expect(user.errors[:name]).to include('is too long (maximum is 50 characters)')
    end
  end
end
