class TagsController < ApplicationController
  before_action :authenticate_user!

  AUTOCOMPLETE_LIMIT = 5

  def autocomplete
    q = params[:q].to_s.strip
    return render json: { tags: [] } if q.blank?

    term = ActiveRecord::Base.sanitize_sql_like(q.downcase)
    pattern = "%#{term}%"

    tags = Tag.for_user(current_user)
              .where("lower(name) LIKE ?", pattern)
              .order(:name)
              .limit(AUTOCOMPLETE_LIMIT)
              .select(:id, :name)

    # サーバー候補タグを JSON で返す
    render json: { tags: tags.map { |t| { id: t.id, name: t.name } } }
  end
end
