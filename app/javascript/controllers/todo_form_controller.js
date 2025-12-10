import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["todoFields", "addButton", "todoTemplate", "todoField"];
  static values = {
    maxCount: { type: Number, default: 5 },
    confirmMessage: { type: String, default: "この項目を削除しますか？" },
  };

  connect() {
    this.updateButtonState();
  }

  add() {
    // canAddでToDoフィールドがmaxCount(Taskが保持するToDoの最大数)を超えてないか判定
    // 超えていない場合、新規追加のToDoフィールドを作成し、ToDo追加ボタンの状態を更新
    if (this.canAdd) {
      this.todoFieldsTarget.appendChild(this.createNewTodo());
      this.updateButtonState();
    }
  }

  remove(event) {
    // クリックされたToDo削除ボタンの親要素(ToDo削除ボタン+ToDoフィールドのコンテナ)を取得
    const todoField = event.target.closest(
      "[data-todo-form-target='todoField']"
    );

    // ブラウザの確認メッセージを表示し、OKが押されたか判定
    // 押された場合、ToDo削除ボタンの親要素(ToDo削除ボタン+ToDoフィールドのコンテナ)を削除し、ToDo追加ボタンの状態を更新
    if (confirm(this.confirmMessageValue)) {
      this.removeTodo(todoField);
      this.updateButtonState();
    }
  }

  updateButtonState() {
    // canAddの真偽により、ToDo追加ボタンのdisabled属性とcssクラスを更新
    const isDisabled = !this.canAdd;

    // disabled属性の更新
    this.addButtonTarget.disabled = isDisabled;

    // cssクラスの更新
    if (isDisabled) {
      this.addButtonTarget.classList.add("opacity-50");
      this.addButtonTarget.classList.add("cursor-not-allowed");
    } else {
      this.addButtonTarget.classList.remove("opacity-50");
      this.addButtonTarget.classList.remove("cursor-not-allowed");
    }
  }

  get canAdd() {
    // ToDoフィールドがmaxCount(Taskが保持するToDoの最大数)を超えてないか判定
    return this.enabledTodoFieldCount < this.maxCountValue;
  }

  get enabledTodoFieldCount() {
    // _destroyフィールドのvalueがfalseのToDoフィールドの数をカウント
    return this.todoFieldTargets.filter((todo) => {
      const destroyField = todo.querySelector('input[name*="[_destroy]"]');
      return !destroyField || destroyField.value == "false";
    }).length;
  }

  removeTodo(todoField) {
    // input要素のname属性:idからToDoのIDを取得
    const todoId = todoField.querySelector('input[name*="[id]"]')?.value;

    if (todoId) {
      // todoIdが存在する(既存のToDoフィールドである)場合
      // _destroyフィールドのvalueをtrueに設定
      todoField.querySelector('input[name*="[_destroy]"]').value = "true";

      // disabled属性の更新
      const textInput = todoField.querySelector('input[type="text"]');
      const removeButton = todoField.querySelector('button[type="button"]');
      if (textInput) textInput.disabled = true;
      if (removeButton) removeButton.disabled = true;

      // cssクラスの更新
      todoField.classList.add("opacity-50");
    } else {
      // 新規追加のToDoフィールドである場合、直接DOMツリーから削除する
      todoField.remove();
    }
  }

  createNewTodo() {
    const template = this.todoTemplateTarget.content.cloneNode(true);
    // ここで取得するToDoフィールドの数は非表示のToDoフィールドも含む
    const allTodoFieldCount = this.todoFieldsTarget.children.length;

    // インデックスを置換
    template.querySelectorAll('input[name*="INDEX"]').forEach((input) => {
      input.name = input.name.replace(/INDEX/g, allTodoFieldCount);
    });

    return template;
  }
}
