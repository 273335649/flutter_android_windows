import request from "@/utils/request";

/**
 * 更换物品序列号
 * @param {Object} data - 请求参数
 * @param {string} data.reqId - 请求ID
 * @param {Array} data.serialNumberList - 序列号列表
 */
export async function changeThings(data) {
  return request({
    url: "/mes-biz/app/step/things/change",
    method: "POST",
    data,
  });
}

/**
 * 物品点检
 * @param {Object} data - 请求参数
 * {
  "items": [
    {
      "id": "",
      "resultStatus": "",
      "resultValue": ""
    }
  ],
  "ngReason": "",
  "ngSerialNumberList": [],
  "reqId": ""
}
 */
export async function thingsCheck(data) {
  return request({
    url: "/mes-biz/app/step/things/check",
    method: "POST",
    data,
  });
}

/**
 * 查询物品点检列表
 * @param {Object} params - 请求参数
 * @param {string} params.reqId - 物品领用ID
 */
export async function getThingsCheckList(params) {
  return request({
    url: "/mes-biz/app/step/things/check/list",
    method: "GET",
    params,
  });
}

/**
 * 查询物品待领用列表
 * @param {Object} params - 请求参数
 * @param {string} params.thingsType - 物品类型，物料工装工具等，关联字典THINGS_TYPE
 * @param {string} params.vin - 机号
 */
export async function getThingsToRequestList(params) {
  return request({
    url: "/mes-biz/app/step/things/to-request/list",
    method: "GET",
    params,
  });
}

/**
 * 查询物品已领用列表
 * @param {Object} params - 请求参数
 * @param {string} params.thingsType - 物品类型，关联字典THINGS_TYPE
 * @param {string} params.vin - 机号
 */
export async function getRequestedThingsList(params) {
  return request({
    url: "/mes-biz/app/step/things/requested/list",
    method: "GET",
    params,
  });
}

/**
 * 物品领用
 * @param {Object} data - 请求参数
 * @param {Array} data.reqContentList - 领用内容列表
 * @param {string} data.reqContentList[].id - 物品ID
 * @param {string} data.reqContentList[].remark - 备注
 * @param {number} data.reqContentList[].reqQty - 领用数量
 * @param {string} data.reqContentList[].reqReason - 领用原因
 * @param {string} data.reqContentList[].stepId - 工步ID
 * @param {string} data.vin - VIN码
 */
export async function reqThings(data) {
  return request({
    url: "/mes-biz/app/step/things/req",
    method: "POST",
    data,
  });
}

/**
 * 查询当前岗位工步记录
 * @param {Object} params - 请求参数
 * @param {string} params.lineId - 产线ID
 * @param {string} params.stationId - 岗位ID
 * @param {string} params.vin - 机号
 */
export async function listStationVinStepLog(params) {
  return request({
    url: "/mes-biz/workOrder/listStationVinStepLog",
    method: "GET",
    params,
  });
}

/**
 * 获取当前工步信息
 * @param {Object} params - 请求参数
 * @param {string} params.lineId - 产线ID
 * @param {string} params.stationId - 岗位ID
 * @param {string} params.vin - 机号
 */
export async function getCurrentStep(params) {
  return request({
    url: "/mes-biz/workOrder/getCurrentStep",
    method: "GET",
    params,
  });
}

/**
 * 物品校验（工步执行页面的物品打勾操作）
 * @param {Object} data - 请求参数
 * @param {string} data.reqId - 物品领用ID
 * @param {string} data.thingsNo - 物品编号或编码
 */
export async function verifyThings(data) {
  return request({
    url: "/mes-biz/app/step/things/verify",
    method: "POST",
    data,
  });
}

/**
 * 查询分箱箱号列表
 * @param {Object} params - 请求参数
 */
export async function getSubBoxList(params) {
  return request({
    url: "/mes-biz/app/step/sub-box/list",
    method: "GET",
    params,
  });
}

/**
 * 物品确认
 * @param {Object} data - 请求参数
 * @param {string} data.reqId - 请求ID
 */
export async function confirmThings(data) {
  const formData = new FormData();
  formData.append("reqId", data.reqId);
  return request({
    url: "/mes-biz/app/step/things/confirm",
    method: "POST",
    data: formData,
  });
}

/**
 * 提交分箱号
 * @param {Object} params - 请求参数
 * @param {string} params.id - 分箱ID(箱号列表返回的ID)
 */
export async function submitSubBox(params) {
  return request({
    url: "/mes-biz/app/step/sub-box/submit",
    method: "POST",
    params,
  });
}

/**
 * 扫描分箱箱标码
 * @param {Object} data - 请求参数
 * @param {string} data.boxCode - 箱标码
 * @param {string} data.boxSerialNo - 箱号
 * @param {string} data.vin - 机号
 */
export async function scanSubBoxCode(data) {
  return request({
    url: "/mes-biz/app/step/sub-box/scan",
    method: "POST",
    data,
  });
}
