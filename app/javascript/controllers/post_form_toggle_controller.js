import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["textForm", "documentForm", "toggle", "textarea"];
  static values = { initialType: String };

  connect() {
    // ポストフォームの初期状態が"DocumentPost"の場合、isDocumentをtrueに設定
    // 以降、isDocumentはToggleのchecked状態と同期する
    const isDocument = this.initialTypeValue === "DocumentPost";
    this.render(isDocument);
    this.resizeAllTextareas();
  }

  toggle(event) {
    this.render(event.currentTarget.checked);
  }

  submitOnEnter(event) {
    if (event.key !== "Enter" || event.shiftKey || event.isComposing) return;

    event.preventDefault();
    event.currentTarget.form?.requestSubmit();
  }

  // フォーム入力時にtextareaの高さを自動調整
  autoResize(event) {
    this.resizeTextarea(event.currentTarget);
  }

  render(isDocument) {
    // 2つのフォームの表示/非表示を切り替え
    this.textFormTarget.classList.toggle("hidden", isDocument);
    this.documentFormTarget.classList.toggle("hidden", !isDocument);

    // 2つのフォームのトグルのchecked状態を更新
    this.toggleTargets.forEach((toggle) => {
      toggle.checked = isDocument;
    });
  }

  // すべてのtextareaの高さを自動調整
  resizeAllTextareas() {
    this.textareaTargets.forEach((textarea) => {
      this.resizeTextarea(textarea);
    });
  }

  // textareaの高さをscrollHeightに合わせて自動調整
  resizeTextarea(textarea) {
    textarea.style.height = "auto";
    textarea.style.height = `${textarea.scrollHeight}px`;
  }
}
