class AddOgpColumnsToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :title, :string
    add_column :documents, :description, :text
    add_column :documents, :image_url, :string
  end
end
