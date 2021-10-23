module.exports = {
  env: {
    browser: true,
    commonjs: true,
    es2020: true,
    node: true,
  },
  parser: "@babel/eslint-parser",
  extends: ["eslint:recommended", "standard", "prettier"],
  parserOptions: {
    ecmaVersion: 11,
    requireConfigFile: "false",
    babelOptions: { configFile: "./.babelrc" },
    sourceType: "module",
  },
  rules: {
    "import/no-extraneous-dependencies": ["error", { packageDir: "." }],
  },
  overrides: [
    {
      files: ["**/tests/**/*.js"],
      env: {
        jest: true,
      },
    },
  ],
};
