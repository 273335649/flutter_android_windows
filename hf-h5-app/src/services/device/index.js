import { request } from "../../utils";
// 点检提交
export const materialSubmitApi = (params) => {
  return request({
    url: `/mes-biz/deviceAction/material`,
    method: "POST",
    body: params,
  });
};
//报修提交
export const warrantySubmitApi = (params) => {
  return request({
    url: `/mes-biz/deviceAction/warranty`,
    method: "POST",
    body: params,
  });
};

//根据设备ID获取设备点检标准列表
export const getCheckStdListApi = (params) => {
  return request({
    url: `/mes-biz/deviceAction/getCheckStdItemByEqptId?eqptId=${params}`,
    method: "get",
  });
};
