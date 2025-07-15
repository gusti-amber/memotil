class AddDefaultStatusToTasks < ActiveRecord::Migration[7.2]
  def change
    change_column_default :tasks, :status, from: nil, to: 0
  end
end
