class CreateMemos < ActiveRecord::Migration[7.2]
  def change
    create_table :memos do |t|
      t.text :body

      t.timestamps
    end
  end
end
