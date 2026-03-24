class AddUserIdToTags < ActiveRecord::Migration[7.2]
  def up
    add_reference :tags, :user, null: true, foreign_key: true

    execute <<-SQL.squish
      CREATE UNIQUE INDEX index_tags_on_lower_name_system
      ON tags (LOWER(name))
      WHERE user_id IS NULL;
    SQL

    execute <<-SQL.squish
      CREATE UNIQUE INDEX index_tags_on_user_id_and_lower_name_user_tags
      ON tags (user_id, LOWER(name))
      WHERE user_id IS NOT NULL;
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_tags_on_user_id_and_lower_name_user_tags;"
    execute "DROP INDEX IF EXISTS index_tags_on_lower_name_system;"
    remove_reference :tags, :user, foreign_key: true
  end
end
