import React, { useState, useEffect, useRef, useCallback } from "react";
import { Form, Select, Upload, Button, message, Flex } from "antd";
import Input from "@/components/Input";
import useIntoVinStep from "@/hooks/useIntoVinStep";
import { useDebounceFn } from "@/hooks/useDebounceFn";
import "./index.less";
import { useModel } from "umi";
import checkedImg from "@/assets/locked.png"; // 开启状态的图片
import uncheckedImg from "@/assets/unlock.png"; // 关闭状态的图片
import dayjs from "dayjs";
import { useModule } from "@/contexts/ModuleContext";
import { getDictListApi, getListApi } from "@/services/common";
import { getVinInfo, reportStation } from "@/services/productionOrder";
import { addReRepairApi } from "@/services/repair";
import useRequest from "@ahooksjs/use-request";
import MyUpload from "@/components/MyUpload/index";
import usePopup from "@/hooks/usePopup";
import useIndexModal from "@/hooks/useIndexModal";
import { getUserDetailApi } from "@/services/demo";
import LoadingImage from "../LoadingImage";
import { CATEGORY } from "@/constants";
const LeftInfo = ({
  isRepairForm = false,
  bottomBtnShow = false,
  checkVin = false,
  bottomBtnReportShow = false,
  getList,
}) => {
  const { openIndexModal } = useIndexModal();
  const { openPopup } = usePopup();
  const { checkIntoVinStep } = useIntoVinStep();

  //isRepairForm 返修表单显示
  //bottomBtnShow 按钮显示

  const {
    sharedState,
    setSharedState,
    updateSharedState,
    clearSharedState,
    updateSharedRef,
    navigateToModule,
    sharedRef,
  } = useModule();
  const { initialState = {}, setInitialState } = useModel("@@initialState");
  const { userInfo = {}, lineId = null, stationId = null } = initialState;
  const [form] = Form.useForm();
  const [faultList, setFaultList] = useState([]);
  const [repairTypeList, setRepairTypeList] = useState([]);
  const [userDetail, setUserDetail] = useState({});
  const [punishCount, setPunishCount] = useState(0);
  const {
    data: engineInfo,
    run: fetchEngineInfo,
    mutate: updateEngineInfo,
  } = useRequest(getVinInfo, {
    manual: true,
    formatResult: (res) => res?.data || res,
    onSuccess: (res) => {
      if (res.message) {
        message.info(res.message);
      } else {
        const { ...reset } = res;
        updateSharedState({
          cardNo: res.cartCode,
          ...reset,
        });
      }
    },
  });

  const { data: reportData, run: postReport } = useRequest(reportStation, {
    manual: true,
    formatResult: (res) => res.data,
  });

  const baseProductInfo = [
    {
      name: sharedState.category === CATEGORY.SUB_ASSEMBLY ? "部装件号" : "机号",
      value: engineInfo?.vin || "-",
    },
    {
      name: "进站时间",
      value: engineInfo?.inboundTime || "-",
    },
    {
      name: "生产订单",
      value: engineInfo?.orderNo || "-",
    },
    {
      name: "SAP订单号",
      value: engineInfo?.scOrderNo || "-",
    },
    {
      name: "物料编码",
      value: engineInfo?.materialCode || "-",
    },
    {
      name: "物料名称",
      value: engineInfo?.materialName || "-",
    },
    {
      name: "当前机型",
      value: engineInfo?.jx || "-",
    },
  ];
  // 如果不是返修表单，则添加前端状态
  const productList = isRepairForm
    ? baseProductInfo
    : [
        ...baseProductInfo,
        {
          name: "前端状态",
          value: engineInfo?.stationStatus ? (engineInfo?.stationStatus === "OK" ? "合格" : "不合格") : "-",
        },
      ];

  const getUserDetail = () => {
    getUserDetailApi(userInfo?.userId).then((res) => {
      const { success, data } = res;
      if (success) {
        setUserDetail(data);
      } else {
        message.warning(res.message);
      }
    });
  };
  //获取人员惩罚数量
  const getLogList = () => {
    const params = {
      current: 1,
      size: 9999,
      tableCode: "MES_FILE_REWARD_PUNISH",
      valueMap: { USER_ID: userInfo?.userId },
      orderMap: { CREATE_TIME: "DESC" },
    };
    getListApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        const punishCount = data?.records?.filter((item) => item && item?.TYPE___L === "惩罚").length;
        setPunishCount(punishCount);
      } else {
        message.warning(res.message);
      }
    });
  };
  //获取返修分类
  const getRepairTypeList = () => {
    const data = "RE_REPAIR_TYPE";
    getDictListApi(data).then((res) => {
      const { success, data } = res;
      if (success) {
        setRepairTypeList(data);
      } else {
        message.warning(res.message);
      }
    });
  };

  //获取故障代码和故障名称
  const getDeviceList = () => {
    const params = {
      current: 1,
      size: 9999,
      tableCode: "MES_FAULT_TYPE",
      valueMap: {},
      orderMap: { CREATE_TIME: "DESC" },
    };
    getListApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setFaultList(data?.records);
      } else {
        message.warning(res.message);
      }
    });
  };
  // 岗位报工
  const handleReport = useCallback(() => {
    if (engineInfo?.vin) {
      postReport({
        vin: engineInfo?.vin,
      });
    }
  }, [engineInfo]);
  //新增返修
  const addRepair = () => {
    let formVal = form.getFieldsValue();
    const params = {
      lineId: lineId,
      stationId: stationId,
      orderNo: engineInfo?.orderNo,
      vinList: engineInfo?.vin,
      type: formVal?.repairType,
      faultFile: JSON.stringify(formVal?.faultFile),
      faultId: formVal?.faultId,
      remark: formVal?.remark,
    };
    if (!formVal.faultFile || formVal.faultFile.length === 0) {
      message.warning("请上传故障附件");
      return;
    }
    if (!formVal.repairType) {
      message.warning("请选择返修类型");
      return;
    }
    if (!formVal.faultId) {
      message.warning("请选择故障代码");
      return;
    }
    if (!formVal.faultName) {
      message.warning("请选择故障名称");
      return;
    }
    addReRepairApi(params).then((res) => {
      const { success } = res;
      if (success) {
        openPopup({
          url: "/modal/loginAccount",
          modalProps: {
            title: "返修登录",
            onCancel: (repaireToken) => {
              console.log("repaireToken: ", repaireToken);
              sessionStorage.setItem("repaireToken", repaireToken);
              if (repaireToken) {
                getList();
              }
            },
          },
        });
      } else {
        message.warning(res.message);
      }
    });
  };
  useEffect(() => {
    if (isRepairForm) {
      getRepairTypeList();
      getDeviceList();
    }
  }, []);
  useEffect(() => {
    if (userInfo) {
      getLogList();
      getUserDetail();
    }
  }, []);
  // 提交表单
  const onFinish = (values) => {
    // 共享状态
    setSharedState(values);
    console.log("表单数据:", values);
  };

  // 自定义防抖函数
  // 使用自定义防抖函数，延迟500ms执行
  const searchStep = useDebounceFn(async (val) => {
    if (!val) {
      // updateEngineInfo(null);
      // clearSharedState();
      // navigateToModule("orderList");
      return;
    }
    if (checkVin) {
      await checkIntoVinStep({ vin: val });
      try {
        // 调用checkIntoVinStep方法检查VIN码
        await fetchEngineInfo({
          vin: val,
          // lineId,
          // stationId,
        }); // 通过机号查询发动机信息

        sharedRef.current.vinSearchInput?.clear?.();
      } catch (error) {
        sharedRef.current.vinSearchInput?.clear?.();
        message.info("检查机号失败");
      }
    } else {
      await fetchEngineInfo({
        vin: val,
        // lineId,
        // stationId,
      }); // 通过机号查询发动机信息
    }
  }, 500);
  return (
    <div className="left-info">
      <div className="title">
        <span>当前人员信息</span>
        {punishCount >= 3 && <span className="tips">当前人员惩罚信息较多，请注意！</span>}
      </div>
      <div className="person-info">
        <div className="pic">
          <LoadingImage style={{ height: "100%", width: "100%" }} src={userDetail?.PORTRAIT} />
        </div>
        <div className="info-list">
          <div>
            <span>姓名：</span>
            <span>{userInfo?.realName || "-"}</span>
          </div>
          <div className="center">
            <span>入司时间：</span>
            <span>{userDetail?.ENTRY_DATE ? dayjs(userDetail?.ENTRY_DATE)?.format("YYYY-MM-DD") : "-"}</span>
          </div>
          <div className="station">
            <div className="current">
              <span>当前岗位：</span>
              <span>{userInfo?.stationName || "-"}</span>
            </div>
            <div
              className="change-btn"
              onClick={() => {
                openIndexModal("positionPage", (result) => {
                  try {
                    const parsedResult = JSON.parse(result);
                    if (parsedResult) {
                      // 更新localStorage中的loginInfo
                      const newLoginInfo = { ...userInfo, ...parsedResult };
                      localStorage.setItem("loginInfo", JSON.stringify(newLoginInfo));
                      // 更新全局initialState
                      setInitialState((prev) => ({
                        ...prev,
                        userInfo: newLoginInfo,
                        stationId: newLoginInfo?.stationId || null,
                        lineId: newLoginInfo?.lineId || null,
                      }));
                      message.success("岗位切换成功！");
                    }
                  } catch (e) {
                    console.error("解析Flutter返回结果失败:", e);
                    message.error("处理返回结果失败！");
                  }
                });
              }}
            >
              切换
            </div>
          </div>
        </div>
      </div>

      <div className="product-info">
        <div className="title">
          <span>当前产品信息</span>
        </div>
        <div className="code-item">
          <div className="scan-code">
            <Input
              ref={(ref) => {
                updateSharedRef("vinSearchInput", ref);
              }}
              allowClear={false}
              placeholder="请扫描或输入"
              onClear={() => {
                updateEngineInfo(null);
                clearSharedState();
                navigateToModule("orderList");
              }}
              onChange={(val) => {
                console.log(`输入：${val}`);
                searchStep(val);
              }}
            />
            {/* <div className="image-switch" onClick={() => setChecked(!checked)}>
              <img src={checked ? checkedImg : uncheckedImg} alt="switch" />
            </div> */}
          </div>
        </div>
        {/* product-list-scroll 超出滚动 */}
        {/* nobtn-list 无按钮 */}
        <div
          className={`product-list ${
            !isRepairForm && !bottomBtnShow ? "nobtn-list" : isRepairForm ? "product-list-scroll" : ""
          }`}
        >
          {productList.map((item, index) => (
            <div className="product-item" key={index}>
              <span className="name">{item.name}</span>
              <span className={`${item.value === "合格" ? "status-color" : ""}`}>{item.value}</span>
            </div>
          ))}
          {isRepairForm && (
            <Form form={form} onFinish={onFinish}>
              <div className="product-item">
                <Form.Item
                  name="repairType"
                  label="返修类型"
                  rules={[{ required: true, message: "请选择" }]}
                  colon={false}
                >
                  <Select
                    placement={"bottomLeft"}
                    getPopupContainer={(triggerNode) => triggerNode.parentNode}
                    placeholder="请选择"
                    style={{ width: 252 }}
                    options={repairTypeList}
                    fieldNames={{ label: "label", value: "id" }}
                  />
                </Form.Item>
              </div>

              <div className="product-item">
                <Form.Item
                  name="faultId"
                  label="故障代码"
                  rules={[{ required: true, message: "请选择" }]}
                  colon={false}
                >
                  <Select
                    placement={"bottomLeft"}
                    getPopupContainer={(triggerNode) => triggerNode.parentNode}
                    placeholder="请选择"
                    style={{ width: 252 }}
                    options={faultList}
                    fieldNames={{ label: "CODE", value: "ID" }}
                  />
                </Form.Item>
              </div>

              <div className="product-item ">
                <Form.Item
                  name="faultName"
                  label="故障名称"
                  rules={[{ required: true, message: "请选择" }]}
                  colon={false}
                >
                  <Select
                    placement={"bottomLeft"}
                    getPopupContainer={(triggerNode) => triggerNode.parentNode}
                    placeholder="请选择"
                    style={{ width: 252 }}
                    options={faultList}
                    fieldNames={{ label: "NAME", value: "NAME" }}
                  />
                </Form.Item>
              </div>

              <div className="product-item nobtn-height" style={{ height: 80 }}>
                <Form.Item
                  name="faultFile"
                  label="故障附件"
                  required
                  colon={false}
                  extra={"最大支持100M支持格式jpg/png/mp4"}
                >
                  <MyUpload
                    fileNum={1}
                    fileSize={100}
                    fileType={["file-JPG", "file-JPEG", "file-PNG"]}
                    getForm={() => {
                      return form.getFieldValue("faultFile");
                    }}
                  />
                </Form.Item>
              </div>
              <div className="product-item">
                <Form.Item name="remark" label="备注" colon={false}>
                  <Input placeholder="请输入" style={{ width: 252, height: 36 }} className={"remark-input"} />
                </Form.Item>
              </div>
            </Form>
          )}
        </div>
        {bottomBtnShow && (
          <div className="bottom-btn">
            {/* <Button
              type="primary"
              htmlType="submit" 
              className="pass-btn"
            >
              合格
            </Button> */}
            {isRepairForm && (
              <Button
                type="primary"
                className="confirm-btn"
                onClick={() => {
                  addRepair();
                }}
              >
                确认
              </Button>
            )}
          </div>
        )}
        {bottomBtnReportShow && (
          <div className="bottom-btn">
            <Button
              type="primary"
              className="confirm-btn"
              onClick={async () => {
                // openPopup({
                //   url: "/modal/crossCheckModal",
                //   modalProps: {
                //     stationName: "stationName",
                //   },
                // });
                // const res = await openRepairPopup();
                // console.log(res, "res123");
                // 岗位报工
                handleReport();
              }}
            >
              确认
            </Button>
          </div>
        )}
      </div>
    </div>
  );
};

export default LeftInfo;
