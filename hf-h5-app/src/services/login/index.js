import { request } from "../../utils";
export const loginApi = (body) => {
  return request({
    url: "/user-center/authentication/form",
    method: "POST",
    body,
  });
};
//退出登录
export const logoutApi = () => {
  return request({
    url: "/user-center/logout",
    method: "POST",
    withoutClientId: true,
  });
};
