module TaskFormHelpers
  # オートコンプリートの表示件数（5件）より多いタグを付けたい場合のテスト用
  def inject_task_tag_ids(tag_ids)
    ids_json = Array(tag_ids).map(&:to_i).to_json
    page.execute_script(<<~JS)
      const ids = #{ids_json};
      const form = document.querySelector('form[action*="/tasks"]');
      ids.forEach(function(id) {
        const h = document.createElement('input');
        h.type = 'hidden';
        h.name = 'task[tag_ids][]';
        h.value = String(id);
        form.appendChild(h);
      });
    JS
  end

  def add_tag_via_autocomplete(tag_name)
    field = find('input[data-test-id="task-tag-search"]')
    page.execute_script("arguments[0].scrollIntoView({block: 'center'})", field.native)
    field.click
    field.set(tag_name)
    expect(page).to have_css('[data-test-id="task-tag-suggestion"]', wait: 10, visible: true)
    find('[data-test-id="task-tag-suggestion"]', match: :first).click
    expect(page).to have_no_css('[data-test-id="task-tag-suggestion"]', wait: 5, visible: true)
  end
end

RSpec.configure do |config|
  config.include TaskFormHelpers, type: :system
end
