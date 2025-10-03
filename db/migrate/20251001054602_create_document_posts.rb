class CreateDocumentPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :document_posts do |t|
      t.references :document, null: false, foreign_key: true

      t.timestamps
    end
  end
end
