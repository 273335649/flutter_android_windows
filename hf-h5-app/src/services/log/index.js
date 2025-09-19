import { request } from "../../utils";
//获取用户操作日志
export const logListApi = (params) => {
  return request({
    url: "/mes-biz/operatorLog/log",
    method: "get",
    params,
  });
};
