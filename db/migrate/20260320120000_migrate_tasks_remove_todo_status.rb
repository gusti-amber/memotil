class MigrateTasksRemoveTodoStatus < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL.squish
      UPDATE tasks SET status = 1 WHERE status = 0
    SQL
    change_column_default :tasks, :status, from: 0, to: 1
  end

  def down
    change_column_default :tasks, :status, from: 1, to: 0
  end
end
