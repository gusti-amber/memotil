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
          green: "#148F57", // Green
          "dark-green": "#233D31", // Dark Green
          "light-gray": "#E8E8E2", // Light Gray
          "off-white": "#F3F3ED", // Off White
          white: "#FCFCF9", // White
          rust: "#A94B2E", // Rust
          purple: "#9733FF", // Purple
        },
      },
    },
  },
  plugins: [
    require("daisyui"),
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ],
};
