class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.string :url, null: false

      t.timestamps
    end
    add_index :documents, :url, unique: true
  end
end
