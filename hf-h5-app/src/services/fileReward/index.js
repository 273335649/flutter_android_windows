import { request } from "../../utils";

//文件设置为已读
export const readFileRewardAPi = (params) => {
  return request({
    url: "/mes-biz/fileRead/read",
    method: "get",
    params,
  });
};
