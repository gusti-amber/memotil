const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        custom: {
          cream: "#FFF8E8", // 背景、テキスト
          beige: "#F7EED3", // カード
          sage: "#8A9A7A", // ボタン
          "sage-white": "#AAB396", // ボタン（ホバー時）
          "sage-dark": "#6B7A5B", // ボタン（ホバー時、明度10%下げ）
          brown: "#674636", // ヘッダー、フッター
        },
      },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ],
};
