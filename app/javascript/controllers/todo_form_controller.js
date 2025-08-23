import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "addButton", "template"];
  static values = { maxCount: { type: Number, default: 3 } };

  connect() {
    this.updateButtonState();
  }

  add() {
    if (this.todoCount >= this.maxCountValue) return;

    const newTodoHtml = this.createNewTodoHtml();
    this.containerTarget.insertAdjacentHTML("beforeend", newTodoHtml);
    this.updateButtonState();
  }

  remove(event) {
    const todoForm = event.target.closest(".flex");
    const todoId = todoForm.querySelector(
      'input[type="hidden"][name$="[id]"]'
    ).value;
    const todoDestroyField = todoForm.querySelector(
      'input[type="hidden"][name$="[_destroy]"]'
    );

    if (confirm("このtodoを削除しますか？")) {
      if (todoId) {
        // 既存のtodoの場合、_destroyフィールドを設定して削除マーク
        todoDestroyField.value = "1";
        todoForm.style.display = "none";
      } else {
        // 新規追加のtodoの場合、直接削除
        todoForm.remove();
      }

      this.updateButtonState();
    }
  }

  updateButtonState() {
    const visibleTodos = this.getVisibleTodos();
    const todoCount = visibleTodos.length;

    if (todoCount >= this.maxCountValue) {
      // 最大数に達した場合、ボタンを無効化
      this.addButtonTarget.disabled = true;
      this.addButtonTarget.classList.add("opacity-50", "cursor-not-allowed");
      this.addButtonTarget.classList.remove("hover:bg-custom-dark-green/80");
    } else {
      // 最大数未満の場合、ボタンを有効化
      this.addButtonTarget.disabled = false;
      this.addButtonTarget.classList.remove("opacity-50", "cursor-not-allowed");
      this.addButtonTarget.classList.add("hover:bg-custom-dark-green/80");
    }
  }

  getVisibleTodos() {
    return Array.from(this.containerTarget.children).filter((todoDiv) => {
      const destroyField = todoDiv.querySelector(
        'input[type="hidden"][name$="[_destroy]"]'
      );
      const isDestroyed = destroyField && destroyField.value === "1";
      const isHidden = todoDiv.style.display === "none";

      return !isDestroyed && !isHidden;
    });
  }

  get todoCount() {
    return this.getVisibleTodos().length;
  }

  createNewTodoHtml() {
    const todoCount = this.containerTarget.children.length;

    return `
      <div class="flex items-center gap-2">
        <button type="button" 
                class="btn btn-circle btn-outline btn-sm border-custom-dark-green text-custom-dark-green hover:bg-custom-dark-green hover:text-custom-white bg-transparent"
                data-action="click->todo-form#remove">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" class="size-4">
            <path d="M5.28 4.22a.75.75 0 0 0-1.06 1.06L6.94 8l-2.72 2.72a.75.75 0 1 0 1.06 1.06L8 9.06l2.72 2.72a.75.75 0 1 0 1.06-1.06L9.06 8l2.72-2.72a.75.75 0 0 0-1.06-1.06L8 6.94 5.28 4.22Z" />
          </svg>
        </button>
        <input type="hidden" name="task[todos_attributes][${todoCount}][_destroy]" value="0" class="hidden">
        <input type="text" 
                name="task[todos_attributes][${todoCount}][body]" 
                placeholder="やることを入力してください" 
                class="input input-bordered flex-1 bg-custom-white border-custom-dark-green text-custom-dark-green focus:border-custom-dark-green focus:ring-2 focus:ring-custom-dark-green/20 focus:outline-none placeholder:text-custom-dark-green/50">
        <input type="hidden" name="task[todos_attributes][${todoCount}][id]" value="">
      </div>
    `;
  }
}
