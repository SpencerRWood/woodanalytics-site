/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./*.{html,htm}",
    "./templates/**/*.{html,htm,jinja,jinja2}",
    "./app/templates/**/*.{html,htm,jinja,jinja2}",
    "./**/*.{js,ts,py}", // if you assemble class strings in code
],
  theme: { extend: {} },
  plugins: [require("daisyui")],
  daisyui: {
    themes: [
      {
        myTheme: {
          "primary": "#040405",
          "primary-content": "#f8f9fa",
          "secondary": "#b7c3cc",
          "secondary-content": "#040405",
          "accent": "#040405",
          "accent-content": "#f8f9fa",
          "neutral": "#f8f9faff",
          "neutral-content": "#040405",
          "base-100": "#f2f4f7",
          "base-content": "#1e2937",
          "info": "#9333ea",
          "info-content": "#fff",
          "success": "#22c55e",
          "success-content": "#fff",
          "warning": "#f59e0b",
          "warning-content": "#fff",
          "error": "#ef4444",
          "error-content": "#fff",
        },
      },
    ],
    defaultTheme: "myTheme",
  },
  // Optional: keep common gaps around even if purge misses them
  safelist: [
    { pattern: /(gap|space-x)-(2|3|4|6|8|10|12)/ },"hidden","block","flex",
    "md:hidden","md:block","md:flex",
  ],
}
