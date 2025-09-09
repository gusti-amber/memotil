import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu", "chatBubble"];
  static classes = ["hidden", "open"];

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
    document.addEventListener("click", this.handleClickOutside);
  }

  hideMenu() {
    this.menuTarget.classList.add(this.hiddenClass);
    this.menuTarget.classList.remove(this.openClass);
    document.removeEventListener("click", this.handleClickOutside);
  }

  // メニューの位置を計算・設定
  positionMenu(event) {
    // 位置を適用
    Object.assign(this.menuTarget.style, {
      position: "fixed",
      left: `${event.clientX}px`,
      top: `${event.clientY}px`,
      zIndex: "9999",
    });
  }

  // 他のコンテキストメニューを閉じる
  hideAllMenus() {
    // 現在開いているメニューを探して閉じる
    const openMenu = document.querySelector(
      '[data-post-context-menu-target="menu"]:not(.hidden)'
    );
    if (openMenu) {
      openMenu.classList.add(this.hiddenClass);
      openMenu.classList.remove(this.openClass);
    }
  }

  handleClickOutside(event) {
    // chat-bubble要素以外をクリックした場合、メニューを閉じる
    if (!this.chatBubbleTarget.contains(event.target)) {
      this.hideMenu();
    }
  }
}
