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
      console.log(`data:`, data);
    } catch (error) {
      console.error(error.message);
    }
  }
}
