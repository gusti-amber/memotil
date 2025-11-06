class AddGithubTokenToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :github_token, :text
  end
end
