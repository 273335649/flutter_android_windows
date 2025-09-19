import { useState } from "react";
// 表格选择逻辑
/**
 * data数据中必须包含唯一值key
 */
export const useSelect = (onSelectChange) => {
  const [selectListObj, setSelectList] = useState({});
  const addSelect = (info) => {
    setSelectList((prev) => {
      const newSelectList = { ...prev, [info.key]: info };
      let selects = Object.values(newSelectList);
      onSelectChange?.(selects?.map((item) => item.key) || [], selects || []);
      return newSelectList;
    });
  };
  const removeSelect = (info) => {
    setSelectList((prev) => {
      const newSelectList = { ...prev };
      delete newSelectList[info.key];
      let selects = Object.values(newSelectList);
      onSelectChange?.(selects?.map((item) => item.key) || [], selects || []);
      return newSelectList;
    });
  };
  const getSelectList = () => {
    return Object.values(selectListObj);
  };
  return {
    getSelectList,
    addSelect,
    removeSelect,
  };
};
export default useSelect;
