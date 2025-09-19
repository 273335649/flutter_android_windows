import { request } from "../../utils";
/**
 * 获取巡检-成品检验列表
 * @param {
 * lineId: 产线ID
 * stationId: 岗位ID
 * } params
 * @returns
 */
export async function listInspVins(params) {
  return request({
    url: "/mes-biz/workOrder/listInspVins",
    method: "GET",
    params,
  });
}
