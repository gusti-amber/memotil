import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static classes = ["hidden", "open"];

  // 定数
  MENU_OFFSET = 10;

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this);
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside);
  }

  showMenu(event) {
    event.preventDefault();
    event.stopPropagation();

    this.hideAllMenus();
    this.menuTarget.classList.remove(this.hiddenClass);
    this.menuTarget.classList.add(this.openClass);
    this.positionMenu(event);
    this.addClickOutsideListener();
  }

  hideMenu() {
    this.menuTarget.classList.add(this.hiddenClass);
    this.menuTarget.classList.remove(this.openClass);
    document.removeEventListener("click", this.handleClickOutside);
  }

  // メニューの位置を計算・設定
  positionMenu(event) {
    const menuRect = this.menuTarget.getBoundingClientRect();
    const viewport = { width: window.innerWidth, height: window.innerHeight };

    let left = event.clientX;
    let top = event.clientY;

    // 画面端を考慮した位置調整
    if (left + menuRect.width > viewport.width) {
      left = viewport.width - menuRect.width - this.MENU_OFFSET;
    }
    if (top + menuRect.height > viewport.height) {
      top = viewport.height - menuRect.height - this.MENU_OFFSET;
    }

    // 位置を適用
    Object.assign(this.menuTarget.style, {
      position: "fixed",
      left: `${left}px`,
      top: `${top}px`,
      zIndex: "9999",
    });
  }

  // クリックアウトサイドのイベントリスナーを追加
  addClickOutsideListener() {
    setTimeout(() => {
      document.addEventListener("click", this.handleClickOutside);
    }, 0);
  }

  // 他のコンテキストメニューをすべて閉じる
  hideAllMenus() {
    document
      .querySelectorAll(
        '[data-controller*="post-context-menu"] [data-post-context-menu-target="menu"]'
      )
      .forEach((menu) => {
        menu.classList.add("hidden");
        menu.classList.remove("dropdown-open");
      });
  }

  handleClickOutside(event) {
    if (
      !this.element.contains(event.target) &&
      !this.menuTarget.contains(event.target)
    ) {
      this.hideMenu();
    }
  }
}
