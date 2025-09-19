import { request } from "../../utils";

export const getUserInfo = (data) => {
  return request({
    url: "/user-center/authentication/form",
    data,
    method: "post",
    headers: { noConfer: "true" },
  });
};

export const getUserFactoryOrg = (data) => {
  return request({
    url: "/mes-biz/org/getUserFactoryOrg",
    data,
    method: "get",
  });
};

export const getListVins = () => {
  return request({
    url: "/listVins",
  });
};

export const getTighteningSteps = () => {
  return request({
    url: "/tighteningSteps",
  });
};

export const getUserDetailApi = (id) => {
  return request({
    url: `/mes-biz/meta/object/detail?tableCode=BASIC_USER&id=${id}`,
    method: "get",
  });
};
