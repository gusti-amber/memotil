import { Controller } from "@hotwired/stimulus";

/**
 * タスク概要（description）の折りたたみ。
 *
 * - content に Tailwind の line-clamp-2 を付け外しして、2行省略 ↔ 全文表示を切り替える。
 * - 実際に省略が必要な長さのときだけ toggleButton を表示する（#updateNeedsToggle）。
 *
 * targets:
 *   content      … 本文。line-clamp-2 の対象
 *   toggleButton … 「もっと表示」「表示を減らす」ボタン
 *   labelMore    … 折りたたみ中のラベル
 *   labelLess    … 展開中のラベル
 */
export default class extends Controller {
  static targets = ["content", "toggleButton", "labelMore", "labelLess"];

  connect() {
    this.#updateNeedsToggle();
  }

  /** クリックで line-clamp をトグルし、ラベルと aria-expanded を同期する */
  toggle() {
    this.contentTarget.classList.toggle("line-clamp-2");
    const isCollapsed = this.contentTarget.classList.contains("line-clamp-2");
    // 折りたたみ中は「もっと表示」、展開中は「表示を減らす」
    this.labelMoreTarget.classList.toggle("hidden", !isCollapsed);
    this.labelLessTarget.classList.toggle("hidden", isCollapsed);
    this.toggleButtonTarget.setAttribute(
      "aria-expanded",
      String(!isCollapsed)
    );
  }

  /**
   * 省略なしの高さと line-clamp 適用後の高さを比較し、
   * 2行で収まるならボタンを隠す。
   */
  #updateNeedsToggle() {
    const el = this.contentTarget;
    el.classList.remove("line-clamp-2");
    const fullHeight = el.scrollHeight;
    el.classList.add("line-clamp-2");
    const clampedHeight = el.clientHeight;

    if (fullHeight <= clampedHeight) {
      this.toggleButtonTarget.classList.add("hidden");
    } else {
      this.toggleButtonTarget.classList.remove("hidden");
    }
  }
}
