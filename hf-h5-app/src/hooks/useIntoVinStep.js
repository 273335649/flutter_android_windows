import { useCallback } from "react";
import { useModel, useNavigate } from "@umijs/max";
import useRequest from "@ahooksjs/use-request";
import { intoVinStation, intoInspStation, reportStep } from "@/services/productionOrder";
import usePopup from "@/hooks/usePopup";
import { Button, Flex, Modal, Tag, message } from "antd";
import { useModule } from "@/contexts/ModuleContext";
import { OPERATION_RESULT, RESULT_CODE, TABLE_CODE, CATEGORY } from "@/constants";
import { useRefresh } from "@/contexts/RefreshContext";
import useContainerNumModal from "@/pages/ModalPages/hooks/useContainerNumModal";

export const useIntoVinStep = () => {
  const { triggerRefresh } = useRefresh();
  const { initialState } = useModel("@@initialState");
  const { updateSharedState, navigateToModule, sharedState } = useModule();
  const { openPopup } = usePopup();
  const navigate = useNavigate();

  const { run: fetchIntoVinStep } = useRequest(intoVinStation, {
    manual: true,
  });

  const { run: fetchIntoInspStep } = useRequest(intoInspStation, {
    manual: true,
  });

  const { run: report } = useRequest(reportStep, {
    manual: true,
    onSuccess: (res) => {
      if (res.success) {
        if (res.data === "1002") {
          Modal.confirm({
            footer: null,
            centered: true,
            width: 400,
            content: <div style={{ fontSize: 26 }}>{res.data?.resultMsg || "报工成功，是否呼叫AGV？"}</div>,
            onOk: () => {
              console.log("点击“呼叫”按钮弹出呼叫AGV弹框");
              Modal.destroyAll();
            },
            okButtonProps: {
              hidden: true,
            },
          });
        }
        message.success(res.message || "报工成功！");
        triggerRefresh(TABLE_CODE.CURRENT_STEP, { source: "report" });
      } else {
        message.info(res.message);
      }
    },
  });

  const openModalTo = ({ selectedVin, res }, callback) => {
    openPopup({
      modalProps: {
        title: "系统提示",
        content: res.data.resultMsg || res.message || "弹窗内容！！！",
        vin: selectedVin.vin,
        onOkArg: true,
        footer: { okText: "确定" },
        onCancel: (arg) => {
          if (arg) {
            callback?.();
          }
        },
      },
    });
  };

  // 选择分箱箱号
  const [openNumModal] = useContainerNumModal({
    onOk: () => {
      navigateToModule("execute");
    },
  });

  // 返修/让步接收
  const openRepairPopup = () => {
    return new Promise((resolve) => {
      openPopup({
        url: "/modal/orderModal",
        modalProps: {
          onCancel: (params) => {
            console.log("刷新页面");
            let type = params?.type;
            setTimeout(() => {
              // 返修
              if (type === "rework") {
                openPopup({
                  url: "/modal/repairConfirmModal",
                  modalProps: {
                    onCancel: (reData) => {
                      console.log(reData, "返修确认填写");
                      resolve(reData);
                    },
                  },
                });
              }
              // 让步接收
              if (type === "conces") {
                openPopup({
                  url: "/modal/loginAccount",
                  modalProps: {
                    onCancel: (bool) => {
                      console.log("让步接收");
                      if (bool) {
                        resolve({
                          resultStatus: OPERATION_RESULT.PASS_OK,
                        });
                      }
                    },
                  },
                });
              }
            }, 100);
          },
        },
      });
    });
  };
  const checkIntoVinStep = useCallback(
    async (selectedVin) => {
      let fetchInto = sharedState?.isInsp ? fetchIntoInspStep : fetchIntoVinStep;
      let params = {
        vin: selectedVin.vin,
        lineId: initialState.lineId,
        stationId: initialState.stationId,
        stationWorkOrderId: selectedVin.workOrderId || "",
      };
      const res = await fetchInto(params);
      if (res?.success) {
        const { resultCode, firstVin, category, vin } = res.data;

        if (firstVin === "Y") {
          await new Promise((resolve) => {
            Modal.confirm({
              footer: null,
              centered: true,
              width: 400,
              content: (
                <>
                  <div style={{ fontSize: 26 }}>{`当前机号${vin}为首件，请确认！`}</div>
                  <Tag
                    color="#2B86FF"
                    style={{ cursor: "pointer", padding: "8px 15px" }}
                    onClick={() => {
                      resolve(true);
                      Modal.destroyAll();
                    }}
                  >
                    确认
                  </Tag>
                </>
              ),
              maskClosable: false,
            });
          });
        }
        let callback = null;
        switch (resultCode) {
          case RESULT_CODE.STEP:
            updateSharedState({ category }, true);
            if (category !== CATEGORY.ACCESSORY_BOXING) {
              navigateToModule("execute");
            } else {
              openNumModal({
                visible: category === CATEGORY.ACCESSORY_BOXING,
                ...params,
              });
            }
            break;
          case RESULT_CODE.REPAIR:
            // 跳转返修工单列表
            navigateToModule("repairList");
            break;
          case RESULT_CODE.TECH_NOTICE:
            // 跳转技术通知
            navigate("/jobFile");
            break;
          case RESULT_CODE.EQPT_CHECK:
            // 跳转设备(点检)
            callback = () => {
              navigate("/device");
            };
            break;
          case RESULT_CODE.MUTUAL_INSPECT:
            callback = () => {
              openPopup({
                url: "/modal/crossCheckModal",
                modalProps: {
                  reqId: res.data?.id,
                  vin: res.data?.vin,
                  stationName: res.data?.stationName,
                },
              });
            };
            break;
          case RESULT_CODE.INSP:
            Modal.confirm({
              footer: null,
              centered: true,
              width: 400,
              content: <div style={{ fontSize: 26 }}>{res.data?.resultMsg || "请等待巡检完成！"}</div>,
              okButtonProps: { hidden: true },
              maskClosable: true,
            });
            break;
          default:
            callback = () => {
              if (process.env.APP_ENV === "dev") {
                openPopup({
                  url: "/modal/crossCheckModal",
                });
              } else {
                // message.info("暂无数据");
              }
            };
            break;
        }
        setTimeout(() => {
          if (callback) {
            openModalTo(
              {
                selectedVin,
                res,
              },
              () => {
                callback?.();
              },
            );
          }
        }, 0);
      } else {
        message.info(res?.message || "获取机号信息失败");
      }
      return res;
    },
    [sharedState],
  );
  // 工步报工
  const onStepFinish = async (values, stepData) => {
    return new Promise((resolve) => {
      if (!stepData?.id) {
        resolve(false);
        return;
      }
      let data = {
        faultFile: "",
        faultId: "",
        remark: "",
        repairType: "",
        resultStatus: values.resultStatus,
        resultValue: typeof values.resultValue === "string" ? values.resultValue : JSON.stringify(values.resultValue),
        stepId: stepData.id,
        // testExcels: [
        //   {
        //     createBy: "",
        //     createName: "",
        //     createTime: "",
        //     file: "",
        //     size: 0,
        //     sortNo: 0,
        //   },
        // ],
        // testPictures: [
        //   {
        //     createBy: "",
        //     createName: "",
        //     createTime: "",
        //     file: "",
        //     size: 0,
        //     sortNo: 0,
        //   },
        // ],
        vin: sharedState.vin,
      };
      if (values.resultStatus === OPERATION_RESULT.NG) {
        openRepairPopup().then((res) => {
          report({
            ...data,
            ...res,
          }).then((res) => {
            if (res.success) {
              resolve(true);
            }
          });
        });
      } else {
        report({
          ...data,
        }).then((res) => {
          if (res.success) {
            resolve(true);
          }
        });
      }
    });
  };

  return {
    onStepFinish,
    checkIntoVinStep,
    openRepairPopup,
  };
};

export default useIntoVinStep;
