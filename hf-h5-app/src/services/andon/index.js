import { request } from "../../utils";
//安灯呼叫
export const andonCallApi = (params) => {
  return request({
    url: "/mes-biz/andon/andonCall",
    method: "post",
    body: params,
  });
}; //通过产线查询安灯类型列表(安灯响应时，需要更新登录token）
export const listAndonTypeApi = (params) => {
  return request({
    url: "/mes-biz/andon/listAndonType",
    method: "get",
    params,
    pathName: params?.isCall ? "andonCall" : "andonResponse",
  });
};
//通过产线ID查询安灯待响应数量
export const getAndonResponseNumApi = (params) => {
  return request({
    url: "/mes-biz/andon/getAndonResponseNum",
    method: "get",
    params,
  });
};

//安灯完结(二次登录接口）
export const andonFinishApi = (params) => {
  return request({
    url: "/mes-biz/andon/andonFinish",
    method: "post",
    body: params,
  });
};
// 安灯响应(二次登录接口）
export const andonResponseApi = (params) => {
  return request({
    url: "/mes-biz/andon/andonResponse",
    method: "post",
    body: params,
  });
};
