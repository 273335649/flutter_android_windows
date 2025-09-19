/*eslint-disable prettier-disable */
/**
 * 项目配置
 */
// host结尾不带/
const host = {
  dev: "https://privatization-gateway-hf-dev.local.360humi.com", // 开发环境
  test: "http://192.168.10.107:3000", // 测试环境
  prod: "http://172.24.0.75:3000", // 正式环境
};

// // 登录地址
// const loginUrls = {
//   dev: "http://login.dev.local.360humi.com/", // 开发环境
//   test: "http://login.fat.local.360humi.com/", // 测试环境
//   prod: "https://auth-hmcloud.360humi.com/", // 正式环境
// };
const ENV = process.env.APP_ENV || "dev"; // 环境
const apiHost = host[ENV];
// const loginPath = loginUrls[ENV];

export { apiHost, ENV };
