import { defineConfig } from "@umijs/max";
import { apiHost } from "./config.app";
import routes from "./routes";

export default defineConfig({
  hash: true,
  antd: {},
  access: {},
  model: {},
  initialState: {},
  jsMinifierOptions: {
    target: ["chrome80", "es2020"], // 确保包含 es2020
  },
  define: {
    "process.env.APP_ENV": process.env.APP_ENV,
    "process.env.APP_LOCAL": process.env.APP_LOCAL,
  },
  extraPostCSSPlugins: [
    require("postcss-pxtorem")({
      rootValue: 16, // 结果为 px 的设计稿元素大小的 1/16，即设计稿元素大小为 32px，自动转换成 2rem
      propList: ["*"], // 可以根据需求选择需要转换的属性，如 ['font', 'font-size', 'width', 'height'] 等
      selectorBlackList: [], // 指定不转换为 rem 的类名，例如 ['body'] 将忽略 body 下的所有 px 转换
      minPixelValue: 2, // 小于或等于2px的将不转换
    }),
  ],
  routes,
  proxy: {
    "/api": {
      target: apiHost,
      changeOrigin: true,
      pathRewrite: { "^/api": "" },
    },
  },
  npmClient: "npm",
});
  