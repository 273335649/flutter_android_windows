/**
 * http请求
 * @Description: config.withoutToken 默认false带token, true 为不带token
 * @Autor: ydd
 * @Date: 2022-10-27
 */
import { message } from "antd";
import axios from "axios";
import { apiHost } from "../../config/config.app";
import { getCookie } from "@/utils";
// 默认配置
const axiosFc = axios.create({
  timeout: 30000,
  headers: {
    "Content-Type": "application/json",
    "X-Requested-With": "XMLHttpRequest",
    noConfer: true,
  },
  withCredentials: false, // 不协带cookie
  // baseURL: "/api", // 添加同意前缀，比如走代理的时候
  // baseURL: apiHost, // 直接走网关
  baseURL: process.env.APP_LOCAL === "true" ? "/api" : apiHost,
});

// 添加请求拦截器
axiosFc.interceptors.request.use(
  async function (config) {
    if (!config.withoutToken) {
      if (config?.pathName === "andonResponse") {
        config.headers["Authorization"] = sessionStorage.getItem("andonToken") || "";
      } else if (config?.pathName === "repair") {
        config.headers["Authorization"] = sessionStorage.getItem("repaireToken") || "";
      } else {
        config.headers["Authorization"] = localStorage.getItem("token") || "";
      }
    }
    return config;
  },
  function (error) {
    // 对请求错误做些什么
    return Promise.reject(error);
  },
);

// 添加响应拦截器
axiosFc.interceptors.response.use(
  function (response) {
    // 2xx 范围内的状态码都会触发该函数。
    // 对响应数据做点什么
    if (Object.prototype.toString.call(response.data) === "[object Blob]") {
      return response;
    }
    return response.data;
  },
  function (error) {
    // 超出 2xx 范围的状态码都会触发该函数。
    // 对响应错误做点什么
    if (error.message === "Network Error") {
      return message.warn("网络错误");
    } else if (error.response.status && error.response.status === 401) {
      // 跳转登录
      // const url = encodeURIComponent(location.href);
      // location.href = loginPath + "?callUrl=" + url;
      message.info(error.response?.data?.message);
    } else if (error.response.status) {
      getStatus(error);
    }
    return Promise.reject(error.response.data);
  },
);

function getStatus(err) {
  const { data = {} } = err.response;
  switch (err.response.status) {
    case 400:
      err.message = `请求错误: ${data.message}`;
      break;

    case 401:
      // err.message = `授权失败: ${data.message}`;
      err.message = `${data.message || "登录信息已过期"}`;
      break;

    case 403:
      err.message = `拒绝访问: ${data.message}`;
      break;

    // case 404:
    //   err.message = "请求地址不正确";
    //   break;
    //
    // case 408:
    //   err.message = "请求超时，稍后再试";
    //   break;
    //
    // case 500:
    //   err.message = "服务器内部错误，稍后再试";
    //   break;
    //
    // case 501:
    //   err.message = "服务未实现，稍后再试";
    //   break;
    //
    // case 502:
    //   err.message = "网关错误，稍后再试";
    //   break;
    //
    // case 503:
    //   err.message = "服务不可用，稍后再试";
    //   break;
    //
    // case 504:
    //   err.message = "网关超时，稍后再试";
    //   break;
    //
    // case 505:
    //   err.message = "HTTP版本不受支持";
    //   break;

    default:
      err.message = "网络错误，稍后再试";
      break;
  }
}

const request = function ({ url, method = "get", body, pathName = null, ...opts }) {
  const reqConfig = {
    url,
    method,
    data: body,
    pathName,
    ...opts,
  };
  return axiosFc(reqConfig);
};

export default request;
