import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];

  search(event) {
    const query = event.target.value.trim();
    this.fetchSuggestions(query);
  }

  // 🎓 fetchAPIについて: https://developer.mozilla.org/ja/docs/Web/API/Fetch_API/Using_Fetch
  async fetchSuggestions(query) {
    // queryを含むURLを作成
    const url = `/tasks/autocomplete?query=${query}`;
    try {
      // fetchAPIで指定したURLにGETリクエストを送信
      const response = await fetch(url);
      // ResponseからJSON形式でデータを取得
      const data = await response.json();
      this.displayResults(data.tasks);
    } catch (error) {
      console.error(error.message);
    }
  }

  displayResults(tasks) {
    if (!tasks.length) {
      this.hideDropdown();
      return;
    }
    this.resultsTarget.innerHTML = tasks
      .map((task) => {
        return `
          <li>
            <button type="button" class="w-full text-left p-2 hover:bg-base-200 rounded"
                    data-action="click->task-search-autocomplete#selectTask">
              ${task.title}
            </button>
          </li>
        `;
      })
      .join("");

    this.resultsTarget.classList.remove("hidden");
  }

  // タスク検索の候補を選択した時の処理
  selectTask(event) {
    const taskTitle = event.currentTarget.textContent.trim();
    // キーワード検索フィールドに選択したタスクのタイトルを表示
    this.inputTarget.value = taskTitle;

    // タスク検索フォームを送信
    const form = this.inputTarget.closest("form");
    if (form) {
      form.requestSubmit();
    }
  }

  hideDropdown() {
    this.resultsTarget.classList.add("hidden");
  }
}
