import { Controller } from "@hotwired/stimulus";

/**
 * タスクフォームのタグ入力（オートコンプリート + バッジ）
 *
 * 【設計方針】
 * - 真実のデータは this.selected のみ。表示（バッジ）と送信（hidden）は render で毎回そこから全描画し同期する。
 * - 候補取得は GET /tags/autocomplete。入力が変わるたびに直前の fetch を AbortController で中断し、古い結果で上書きされないようにする。
 * - 送信: 既存タグは task[tag_ids][]（ID）、オートコンプリートに無い新規名のみ task[new_tag_names][]（名前）。
 * - 候補クリックは mousedown（blur が先に走り click が届かないのを防ぐ）。候補外しは blur を少し遅らせてクリックと競合しにくくする。
 */
export default class extends Controller {
  static targets = ["input", "results", "badgeContainer", "hiddenContainer"];
  static values = { initialTags: Array };

  // 編集時は initialTags から this.selected を埋め、render でバッジ + hidden を復元する
  connect() {
    this.selected = [];
    this.blurTimeout = null;
    this.fetchAbort = null;

    // 編集時は initialTags から this.selected を埋める
    (this.hasInitialTagsValue ? this.initialTagsValue : []).forEach((t) => {
      if (t?.id && t?.name) this.pushExisting(Number(t.id), String(t.name));
    });
    this.render();
  }

  disconnect() {
    clearTimeout(this.blurTimeout);
    this.abortPendingFetch();
  }

  // 新しい検索の直前に呼ぶ。遅れて返ったレスポンスで一覧が上書きされるのを防ぐ
  abortPendingFetch() {
    this.fetchAbort?.abort();
    this.fetchAbort = null;
  }

  // input イベントで発火。trim せずそのまま q を送る。空なら候補を閉じる
  search() {
    const q = this.inputTarget.value;
    if (q.length === 0) {
      this.hideDropdown();
      return;
    }
    this.fetchSuggestions(q);
  }

  // q は search または onFocus から渡す（このメソッド内では inputTarget を読まない）
  // GET /tags/autocomplete?q=…
  // → サーバーが Tags 等から候補を検索し JSON（tags 配列）を返す
  // → displayResults に渡して一覧を描画
  async fetchSuggestions(q) {
    this.abortPendingFetch();
    this.fetchAbort = new AbortController();
    const { signal } = this.fetchAbort;
    try {
      const res = await fetch(
        `/tags/autocomplete?${new URLSearchParams({ q })}`,
        {
          credentials: "same-origin",
          signal,
        },
      );
      this.displayResults((await res.json()).tags || [], q);
    } catch (e) {
      if (e.name !== "AbortError") console.error(e.message);
    } finally {
      this.fetchAbort = null;
    }
  }

  // tags: サーバー候補タグ q: 入力クエリ
  // tagsToShow: 表示するタグの配列（サーバー候補タグ + 入力クエリ）
  displayResults(tags, q) {
    // サーバー候補タグから選択済みタグを除外
    const taken = new Set(
      this.selected.map((s) => s.id).filter((id) => id != null),
    );
    const filteredTags = tags.filter((t) => !taken.has(t.id));

    // q と同名のタグがあるかどうかのチェック
    const qLower = q.trim().toLowerCase();
    const hasQueryMatch = tags.some((t) => t.name.toLowerCase() === qLower);

    // tagsToShow: 表示するタグの配列（サーバー候補タグ + 入力クエリ）
    const tagsToShow = [
      ...filteredTags.map((t) => ({ id: t.id, name: t.name })),
      ...(hasQueryMatch ? [] : [{ id: null, name: q }]),
    ];

    // 表示するタグがなければドロップダウンを閉じる
    if (tagsToShow.length === 0) {
      this.hideDropdown();
      return;
    }

    // 候補タグの一括描画
    this.resultsTarget.innerHTML = tagsToShow
      .map(
        (t) => `<li>
                  <button type="button"
                    data-test-id="task-tag-suggestion"
                    class="w-full text-left px-3 py-2 text-sm rounded hover:bg-surface-elevated"
                    data-action="mousedown->tag-autocomplete#selectTag"
                    ${t.id != null ? `data-tag-id="${t.id}"` : ""}
                    data-label="${this.escapeAttr(t.name)}">
                    <span>${this.escapeHtml(t.name)}</span>
                  </button>
                </li>`,
      )
      .join("");
    this.resultsTarget.classList.remove("hidden");
  }

  // data-tag-id あり: 既存タグ。なし: 入力文字列を新規として tryAddNewTag（成功時はそちらで reset）
  selectTag(event) {
    event.preventDefault();
    event.stopPropagation();
    this.abortPendingFetch();
    const { tagId, label } = event.currentTarget.dataset;
    if (tagId !== undefined && tagId !== "") {
      this.pushExisting(Number(tagId), label);
      this.resetInputAndClose();
    } else {
      this.tryAddNewTag(label);
    }
  }

  // Enter: 候補が開いていれば先頭の既存タグを確定、なければ新規名として tryAddNewTag
  keydown(event) {
    if (event.key !== "Enter") return;
    event.preventDefault();
    const q = this.inputTarget.value;
    if (q.length === 0) return;

    // first: 先頭の既存タグ
    const first = this.resultsTarget.querySelector("[data-tag-id]");
    if (first && !this.resultsTarget.classList.contains("hidden")) {
      this.abortPendingFetch();
      this.pushExisting(Number(first.dataset.tagId), first.dataset.label);
      this.resetInputAndClose();
      return;
    }
    this.tryAddNewTag(q);
  }

  tryAddNewTag(name) {
    const trimmed = name.trim();
    if (trimmed.length === 0) return;
    if (this.hasName(trimmed)) {
      this.inputTarget.value = "";
      return;
    }
    this.selected.push({ id: null, name: trimmed, isNew: true });
    this.resetInputAndClose();
  }

  // 入力クリア → 候補ドロップダウン閉じる → render でバッジと hidden を this.selected に合わせて更新
  resetInputAndClose() {
    this.inputTarget.value = "";
    this.hideDropdown();
    this.inputTarget.blur();
    this.render();
  }

  // 既存タグを selected に足す。同一 id または同一名前（大文字小文字無視）が既にあれば push せず棄却
  pushExisting(id, name) {
    if (this.selected.some((s) => s.id === id)) return;
    if (this.hasName(name)) return;
    this.selected.push({ id, name, isNew: false });
  }

  // selected 内に同じ名前（大文字小文字無視）があるか（新規 id:null の行も含めて比較）
  hasName(name) {
    const lower = name.toLowerCase();
    return this.selected.some((s) => s.name.toLowerCase() === lower);
  }

  remove(event) {
    const index = Number(event.currentTarget.dataset.index);
    if (Number.isNaN(index)) return;
    this.selected.splice(index, 1);
    this.render();
  }

  // this.selected を唯一の元に全描画:
  // バッジタグは innerHTML で一括差し替え
  // フォーム送信用のhidden要素(既存タグと新規タグ名)は replaceChildren で一括差し替え
  render() {
    this.badgeContainerTarget.innerHTML = this.selected
      .map((s, i) => {
        const label = this.escapeHtml(s.name);
        return `<span class="join join-horizontal">
                  <span class="badge badge-soft badge-neutral join-item rounded-l-full pr-2">${label}</span>
                  <button type="button"
                    class="btn btn-soft btn-xs join-item rounded-r-full"
                    data-action="click->tag-autocomplete#remove"
                    data-index="${i}"
                    aria-label="タグを削除">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" fill="currentColor" class="size-4">
                      <path d="M5.28 4.22a.75.75 0 0 0-1.06 1.06L6.94 8l-2.72 2.72a.75.75 0 1 0 1.06 1.06L8 9.06l2.72 2.72a.75.75 0 1 0 1.06-1.06L9.06 8l2.72-2.72a.75.75 0 0 0-1.06-1.06L8 6.94 5.28 4.22Z" />
                    </svg>
                  </button>
                </span>`;
      })
      .join("");

    this.hiddenContainerTarget.replaceChildren(
      ...this.selected.map((s) => {
        const inp = document.createElement("input");
        inp.type = "hidden";
        if (s.isNew) {
          inp.name = "task[new_tag_names][]";
          inp.value = s.name;
        } else {
          inp.name = "task[tag_ids][]";
          inp.value = String(s.id);
        }
        return inp;
      }),
    );
  }

  onFocus() {
    clearTimeout(this.blurTimeout);
    const q = this.inputTarget.value;
    if (q.length >= 1) this.fetchSuggestions(q);
  }

  // 少し遅らせて閉じると、候補クリック（mousedown）が先に処理されやすい
  onBlur() {
    this.blurTimeout = setTimeout(() => this.hideDropdown(), 300);
  }

  hideDropdown() {
    this.resultsTarget.innerHTML = "";
    this.resultsTarget.classList.add("hidden");
  }

  // innerHTML へ差し込む文字列をエスケープし、タグとして解釈されないようにする（XSS対策）
  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  }

  // 属性値用。引用符などで属性を壊したり注入されたりしないようにする
  escapeAttr(text) {
    return String(text)
      .replace(/&/g, "&amp;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }
}
