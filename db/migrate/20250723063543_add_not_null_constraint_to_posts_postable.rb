class AddNotNullConstraintToPostsPostable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :posts, :postable_type, false
    change_column_null :posts, :postable_id, false
  end
end
