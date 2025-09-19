import { OPERATION_RESULT, STEP_OPERATE_TYPE } from "@/constants";

// 部分业务逻辑公用hook
const useCommon = () => {
  // 录入校验检查输入值是否在范围内
  const isInspection = ({ row, val }) => {
    const { inspectionStd, opType } = row.original;
    return new Promise((resolve) => {
      if (opType === STEP_OPERATE_TYPE.TYPE_IN.code) {
        if (!val) {
          resolve(false);
        } else {
          if (typeof inspectionStd === "string" && inspectionStd.includes("~")) {
            const [min, max] = inspectionStd.split("~").map(Number);
            // 检查输入值是否在范围内
            if (!isNaN(val) && !isNaN(min) && !isNaN(max) && val >= min && val <= max) {
              resolve(OPERATION_RESULT.OK);
            } else {
              resolve(OPERATION_RESULT.NG);
            }
          } else {
            resolve(false);
          }
        }
      } else {
        resolve(false);
      }
    });
  };
  return { isInspection };
};

export { useCommon };
