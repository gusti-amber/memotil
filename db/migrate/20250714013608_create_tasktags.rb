class CreateTasktags < ActiveRecord::Migration[7.2]
  def change
    create_table :tasktags do |t|
      t.references :task, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
