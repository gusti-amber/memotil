# frozen_string_literal: true

class AddDescriptionToTasks < ActiveRecord::Migration[7.2]
  def change
    add_column :tasks, :description, :text
  end
end
