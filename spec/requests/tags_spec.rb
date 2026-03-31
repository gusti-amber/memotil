require "rails_helper"

RSpec.describe "Tags", type: :request do
  describe "GET /tags/autocomplete" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it "未ログインの場合はログイン画面へリダイレクトする" do
      get autocomplete_tags_path(q: "ab")
      expect(response).to redirect_to(new_user_session_path)
    end

    context "ログイン済み" do
      before { sign_in user }

      it "q が空のときは空配列を返す" do
        get autocomplete_tags_path(q: "")
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["tags"]).to eq([])
      end

      it "q が1文字でも部分一致するタグを返す" do
        create(:tag, name: "alpha", user_id: nil)

        get autocomplete_tags_path(q: "a")
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["tags"].size).to eq(1)
        expect(json["tags"].first["name"]).to eq("alpha")
      end

      it "空白のみの q は空配列を返す" do
        get autocomplete_tags_path(q: "  ")
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["tags"]).to eq([])
      end

      it "システムタグと自分のタグのみ候補に含め、他ユーザーのタグは含めない" do
        system_tag = create(:tag, name: "alpha_system", user_id: nil)
        mine = create(:tag, :for_user, name: "alpha_mine", user: user)
        create(:tag, :for_user, name: "alpha_other", user: other_user)

        get autocomplete_tags_path(q: "alp")
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        ids = json["tags"].map { |t| t["id"] }
        expect(ids).to contain_exactly(system_tag.id, mine.id)
      end

      it "名前の部分一致（大文字小文字を区別しない）で返す" do
        create(:tag, name: "RubyGuide", user_id: nil)

        get autocomplete_tags_path(q: "ruby")
        json = response.parsed_body
        expect(json["tags"].size).to eq(1)
        expect(json["tags"].first["name"]).to eq("RubyGuide")
      end

      it "件数は最大5件に制限する" do
        6.times do |i|
          create(:tag, name: format("tag_%02d_match", i), user_id: nil)
        end

        get autocomplete_tags_path(q: "match")
        json = response.parsed_body
        expect(json["tags"].size).to eq(5)
      end
    end
  end
end
