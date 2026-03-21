module TodoSpecHelpers
  def click_show_todo_form_button
    find('[data-test-id="show-todo-form-button"]', visible: :visible).click
  end

  def click_add_todo_field_button
    find('[data-test-id="add-todo-field-button"]').click
  end
end

RSpec.configure do |config|
  config.include TodoSpecHelpers, type: :system
end
