module.exports = {
  extends: [
    require.resolve("@umijs/max/eslint"),
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
  ],
  plugins: ["@typescript-eslint", "react"],
  // 可以全局使用变量
  globals: {
    React: true,
  },
  rules: {
    "prettier/prettier": [
      "error",
      {
        endOfLine: "auto",
      },
    ],
    camelcase: ["error", { properties: "never" }],
  },
  settings: {
    react: {
      version: "999.999.999",
    },
  },
};
