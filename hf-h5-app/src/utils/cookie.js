/**
 * cookie方法
 * @Description: 所有cookie处理都在这里，新增key，也定义到这里， 如：HM_TOKEN
 * @Autor: ydd
 * @Date: 2022-10-27
 */
import Cookies from "js-cookie";
import regex from "./regx";

const cookieKeys = {
  accessToken: "HM_TOKEN",
};

const hostname = location.hostname;
const domain = regex.isIP(hostname) ? hostname : hostname.split(".").slice(-2).join(".");

export const setCookie = (values = {}) => {
  Object.keys(values).forEach((key) => {
    Cookies.set(cookieKeys[key], values[key], { domain, expires: 365 });
  });
};

export const clearAllCookie = () => {
  Object.values(cookieKeys).forEach((name) => {
    Cookies.remove(name, { domain });
  });
};

export const getCookie = (key) => {
  let nKey = key;
  const index = Object.keys(cookieKeys).findIndex((v) => v === nKey);
  if (index !== -1) {
    nKey = cookieKeys[nKey];
  }
  return Cookies.get(nKey, { domain });
};
