import { request } from "../../utils";
// 第一次请求：上传文件
export const postFileUpload = (formData) => {
  return request({
    url: `/mes-biz/file/upload`,
    method: "post",
    body: formData,
  });
};
//获取上传后的文件信息
export const getUploadInfo = (params) => {
  return request({
    url: `/mes-biz/meta/column/getUploadInfo`,
    method: "get",
    params,
  });
};
//获取列表通用
export const getListApi = (params) => {
  return request({
    url: `/mes-biz/meta/object/page?current=${params.current}&size=${params.size}`,
    method: "post",
    body: params,
  });
};
//数据字典
//获取故障分类FAULT_CATEGORY
export const getDictListApi = (params) => {
  return request({
    url: `/mes-biz/dict/dictData/listByType?dictType=${params}`,
    method: "get",
  });
};
