/**
 * @Description: 控制台日志打印
 * @Autor: ydd
 * @Date: 2022-9-21
 */
const ENV = process.env.APP_ENV || "dev"; // 环境
const isDev = ENV === "dev";

export const LOG = {
  info: (...text) => isDev && console.info.apply(this, ["HM[info]", ...text]),
  error: (...text) => isDev && console.error.apply(this, ["HM[error]", ...text]),
};
