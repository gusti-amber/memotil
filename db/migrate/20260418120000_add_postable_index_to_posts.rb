class AddPostableIndexToPosts < ActiveRecord::Migration[7.2]
  def change
    add_index :posts, [:postable_type, :postable_id]
  end
end
