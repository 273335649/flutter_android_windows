import request from "@/utils/request";
import { getTighteningSteps } from "@/services/demo";
/**
 * 查询工单列表
 * @param {
 * lineId: 产线ID
 * stationId: 岗位ID
 * } params
 * @returns
 */
export async function listTodayAndUndoStationOrders(params) {
  return request({
    url: "/mes-biz/workOrder/listTodayAndUndoStationOrders",
    method: "GET",
    params: params,
  });
}

// {
//     "id": "", //工单ID
//     "scheduleId": "", //排产计划ID
//     "processRouteId": "", //工艺路线
//     "materialCode": "", //物料
//     "lineId": "", //产线
//     "stationId": "", //岗位
//     "scheduleQty": 0, //计划排产数
//     "inQty": 0, //入站数
//     "outQty": 0, //出站数
//     "okQty": 0, //合格数
//     "status": "", //状态
//     "startTime": "", //开始时间
//     "endTime": "", //结束时间
//     "type": "", //生产/测试/包装/研发测试/返修
//     "scheduleNo": "", //排产号
//     "ztbm": "", //ZTBM
//     "materialName": "", //物料名称
//     "processRouteNo": "", //工艺路线编码
//     "startDay": "", //计划开始i日期
//     "endDay": "", //计划结束日期
//     "planQty": 0, //计划生产数量
//     "inQtyOnline": 0, //上线数量
//     "outQtyOffline": 0, //下线数量
//     "edQty": 0, //已排产数量
//     "waitQty": 0, //待排产数量
//     "parentId": "", //上级排产ID
//     "parentNo": "", //上级排产NO
//     "orderNo": "", //装配订单号
//     "zpjhh": "", //排产计划号
//     "scddlx": "", //生产订单类型
//     "jx": "", //机型
//     "scOrderNo": "", //生产订单号
//     "faultId": "", //故障信息ID
//     "faultFile": "", //故障信息附件
//     "remark": "", //备注
//     "No": "", //返修订单号
//     "repairStatus": "", //返修工单状态
//     "repairId": "", //返修工单ID
//     "vins": [ //机号列表
//         ""
//     ],
//     "no": ""
// }

/**
 * 查询返修工单列表
 * @param {
 * lineId: 产线ID
 * stationId:	岗位ID
 * } params
 * @returns
 */
export async function listRepairOrders(params) {
  return request({
    url: "/mes-biz/workOrder/listRepairOrders",
    method: "GET",
    params: params,
  });
}

/**
 * 查询机号列表
 * @param {type: 	1=正常工单，2=返修工单, search: 工单ID，工装车二维码，生产订单号, scheduleLogId:, stationId: 岗位id} params
 * @returns
 */
export async function listVins(params) {
  // const isDev = process.env.APP_ENV === "dev";
  // if (isDev) {
  //   return getListVins();
  // } else {
  return request({
    url: "/mes-biz/workOrder/listVins",
    method: "GET",
    params,
  });
  // }
}

/**
 * 通过机号查询发动机信息
 * @param {vin: 机号, type（1=正常工单，2=返修工单）} params
 * @returns
 */
export async function getVinInfo(data) {
  return request({
    url: "/mes-biz/workOrder/getVinInfo",
    method: "POST",
    data,
  });
}

/**
 * 工单列表-进入工步操作
 * @param {
 * lineId: 产线ID
 * stationId: 岗位ID
 * vin: 机号
 * } params
 * @returns
 */
export async function intoVinStation(params) {
  return request({
    url: "/mes-biz/workOrder/intoVinStation",
    method: "GET",
    params: params,
  });
}

/**
 * 巡检列表-进入工步操作
 * @param {
 * lineId: 产线ID
 * stationId: 岗位ID
 * vin: 机号
 * } params
 * @returns
 */
export async function intoInspStation(params) {
  return request({
    url: "/mes-biz/workOrder/intoInspStation",
    method: "GET",
    params: params,
  });
}

/**
 * 获取拧紧工步列表
 * @param {
 * stationId: 岗位ID
 * stepId: 步骤ID
 * vin: 机号
 * } params
 * @returns
 */
export async function getStepSub(params) {
  // return getTighteningSteps();
  return request({
    url: "/mes-biz/workOrder/getStepSub",
    method: "get",
    params: params,
  });
}
// {
//   "faultFile": "",
//   "faultId": "",
//   "remark": "",
//   "repairType": "",
//   "resultStatus": "",
//   "resultValue": "",
//   "stepId": "",
//   "testExcels": [
//     {
//       "createBy": "",
//       "createName": "",
//       "createTime": "",
//       "file": "",
//       "size": 0,
//       "sortNo": 0
//     }
//   ],
//   "testPictures": [
//     {
//       "createBy": "",
//       "createName": "",
//       "createTime": "",
//       "file": "",
//       "size": 0,
//       "sortNo": 0
//     }
//   ],
//   "vin": ""
// }
/**
 * 工步报工
 * @param {object} data
 * @returns
 */
export async function reportStep(data) {
  return request({
    url: "/mes-biz/app/step/report",
    method: "POST",
    data: data,
  });
}

/**
 * 岗位报工
 * @param {
 * {vin}
 * } data
 * @returns
 */
export async function reportStation(data) {
  return request({
    url: "/mes-biz/app/station/report",
    method: "POST",
    data: data,
  });
}

/**
 * 查询岗位互检项目列表（返回空列表表示无需互检）
 * @param {vin} params
 * @returns
 */
export async function getMutualInspectList(params) {
  return request({
    url: "/mes-biz/app/mutual/inspect/list",
    method: "GET",
    params: params,
  });
}
// {
//   "contentList": [
//     {
//       "id": "",
//       "inspectImage": "",
//       "inspectResult": "",
//       "remark": ""
//     }
//   ],
//   "faultFile": "",
//   "faultId": "",
//   "operateType": "",
//   "remark": "",
//   "repairType": "",
//   "vin": ""
// }
/**
 * 执行岗位互检（包括互检完成、让步接收、返修）
 * @param {object} data
 * @returns
 */
export async function executeMutualInspect(data) {
  return request({
    url: "/mes-biz/app/mutual/inspect/execute",
    method: "POST",
    data: data,
  });
}
