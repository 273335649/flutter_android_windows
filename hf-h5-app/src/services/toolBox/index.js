import request from "@/utils/request";

/**
 * 获取未结束的排产Log
 * @param {{vin}} params
 * @returns
 */
export async function getNotFinishSchedule(data) {
  return request({
    url: "/mes-biz/schedule/getNotFinishScheduleByVin",
    method: "POST",
    data: data,
  });
}

/**
 * 发动机上线绑定
 * @param {{
 * "carNo": "",
 * "stationLogId": "",
 * "vin": ""
 * }} data
 * @returns
 */
export async function bindCar(data) {
  return request({
    url: "/mes-biz/vin/bindCar",
    method: "POST",
    data: data,
  });
}

/**
 * 机号下线解绑
 * @param {{vin:string, carNo:string, stationLogId:string}} data
 * @returns
 */
export async function unBindCar(data) {
  return request({
    url: "/mes-biz/vin/unBindCar",
    method: "POST",
    data: data,
  });
}
