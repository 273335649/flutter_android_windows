/**
 * px转rem
 * @param px
 * @returns {string}
 */
export const px2rem = (px) => {
  const rootValue = 16;
  return `${px / rootValue}rem`;
};

/*
常用方法
 */
import { setCookie } from "./cookie";
/**
 * 下载二进制文件
 * @param data 数据流
 * @param filename 文件名
 */
export const downloadBlobFile = (data, filename) => {
  if (!data || !filename) return;
  const name = decodeURIComponent(filename);
  let url = window.URL.createObjectURL(new Blob([data], { type: "octet/stream" }));
  let link = document.createElement("a");
  link.style.display = "none";
  link.href = url;
  link.setAttribute("download", name);
  document.body.appendChild(link);
  link.click();
};

/**
 * 字符串转换成base64
 * @param str 字符串
 * @returns {string}
 */
export const toBase64 = (str) => {
  return btoa(
    encodeURIComponent(str).replace(/%([0-9A-F]{2})/g, function (match, p1) {
      return String.fromCharCode(Number("0x" + p1));
    }),
  );
};

/**
 * 对象转换为queryString
 * @param params
 * @returns {string}
 */
export const queryString = (params) => {
  return Object.keys(params)
    .map((key) => key + "=" + params[key])
    .join("&");
};

// 保存url中的token

export const saveTokenFromUrl = (callback = false) => {
  const url = new URL(location.href);
  const token = url.searchParams.get("access_token");
  url.searchParams.delete("access_token");
  if (token) {
    setCookie({
      accessToken: token,
    });
    window.history.replaceState(null, null, url);
  }
  if (callback) {
    return {
      token,
      url: url.toString(),
    };
  }
};
