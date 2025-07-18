class CreateTodos < ActiveRecord::Migration[7.2]
  def change
    create_table :todos do |t|
      t.references :task, null: false, foreign_key: true
      t.string :body, null: false
      t.boolean :done, default: false, null: false

      t.timestamps
    end
  end
end
