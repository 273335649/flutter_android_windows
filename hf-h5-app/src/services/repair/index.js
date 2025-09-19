import { request } from "../../utils";
//新增返修信息
export const addReRepairApi = (params) => {
  return request({
    url: `/mes-biz/reRepair/add`,
    method: "POST",
    body: params,
    pathName: "repair",
  });
};
