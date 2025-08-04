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
          sage: "#AAB396", // 基準色
          "sage-light": "#C4D1B8", // sageより10%明度が明るい
          "sage-dark": "#8A9A7A", // sageより10%明度が暗い
          brown: "#674636", // ヘッダー、フッター
          "brown-light": "#7A5646", // brownより明度10%明るい
          "brown-dark": "#543628", // brownより明度10%暗い
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
