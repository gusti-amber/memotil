import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["todoFields", "addButton", "template", "todoField"];
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
      this.addButtonTarget.classList.add("btn-disabled");
      this.addButtonTarget.classList.add("opacity-50");
      this.addButtonTarget.classList.add("cursor-not-allowed");
    } else {
      this.addButtonTarget.classList.remove("btn-disabled");
      this.addButtonTarget.classList.remove("opacity-50");
      this.addButtonTarget.classList.remove("cursor-not-allowed");
    }
  }

  get canAdd() {
    // ToDoフィールドがmaxCount(Taskが保持するToDoの最大数)を超えてないか判定
    return this.todoCount < this.maxCountValue;
  }

  get todoCount() {
    // 非表示のtodoはフィルタリングし、表示されているtodoの数をカウント
    return this.todoFieldTargets.filter((todo) => todo.style.display !== "none")
      .length;
  }

  removeTodo(todoField) {
    // input要素のname属性:idからToDoのIDを取得
    const todoId = todoField.querySelector('input[name*="[id]"]')?.value;

    if (todoId) {
      // todoIdが存在する(既存のToDoフィールドである)場合
      // _destroyをtrueにして、ToDoフィールドを非表示にする
      todoField.querySelector('input[name*="[_destroy]"]').value = "true";
      todoField.style.display = "none";
    } else {
      // 新規追加のToDoフィールドである場合、直接DOMツリーから削除する
      todoField.remove();
    }
  }

  createNewTodo() {
    const template = this.templateTarget.content.cloneNode(true);
    // ここで取得するtodoの数は非表示のtodoも含む
    const todoCount = this.todoFieldsTarget.children.length;

    // インデックスを置換
    template.querySelectorAll('input[name*="INDEX"]').forEach((input) => {
      input.name = input.name.replace(/INDEX/g, todoCount);
    });

    return template;
  }
}
