import React, { useState, useEffect } from "react";
import { Button, Tabs, Space, Modal } from "antd";
import RepairTable from "./repairTable";
import WorkStepsTable from "./workStepsTable";
import WorkStepsRecordTable from "./workStepsRecordTable";
import usePopup from "@/hooks/usePopup";
import { useModule } from "@/contexts/ModuleContext";
import { CATEGORY, TABLE_CODE } from "@/constants";
import { getCurrentStep } from "@/services/stepRequisition";
import { useModel } from "@umijs/max";
import useTableRefresh from "@/hooks/useTableRefresh";

const WorkingSteps = () => {
  const { openPopup } = usePopup();
  const { sharedState, navigateToModule } = useModule();
  const { initialState } = useModel("@@initialState");

  const [activeIndex, setActiveIndex] = useState("0");

  // 使用通用表格刷新Hook
  const { data: stepData, loading: stepLoading } = useTableRefresh(
    getCurrentStep,
    TABLE_CODE.CURRENT_STEP,
    {
      lineId: initialState.lineId,
      stationId: initialState.stationId,
      vin: sharedState.vin,
    },
    {
      onSuccess: (res) => {
        if (res?.opType === "AUTOMATIC") {
          navigateToModule("tighten");
        }
        console.log(res, "13456");
        if (res.message) {
          Modal.confirm({
            footer: null,
            centered: true,
            width: 400,
            content: <div style={{ fontSize: 26 }}>{res.message}</div>,
            okButtonProps: { hidden: true },
          });
          setTimeout(() => {
            if (!res.success) {
              navigateToModule("orderList");
            }
            Modal.destroyAll();
          }, 3000);
        }
      },
      formatResult: (res) => res?.data || res,
      dependencies: [sharedState.vin], // 当vin变化时自动刷新数据
    },
  );

  const items = [
    {
      key: "0",
      label: "工步",
      Content: <WorkStepsTable stepData={stepData} stepLoading={stepLoading} />,
    },
    {
      key: "1",
      label: "工步记录",
      Content: <WorkStepsRecordTable stepData={stepData} stepLoading={stepLoading} />,
    },
  ];

  const onChange = (key) => {
    setActiveIndex(key);
  };

  return (
    <>
      <RepairTable stepData={stepData} stepLoading={stepLoading} />
      <Tabs
        defaultActiveKey="0"
        indicator={{
          size: (origin) => origin - 20,
          align: "center",
        }}
        items={items}
        onChange={onChange}
        tabBarExtraContent={
          sharedState.category === CATEGORY.TESTING && (
            <Space style={{ marginRight: "16px" }}>
              <Button
                className="base-btn"
                onClick={() =>
                  openPopup({
                    url: "/modal/uploadImage",
                  })
                }
              >
                上传图片
              </Button>
              <Button
                className="base-btn"
                onClick={() =>
                  openPopup({
                    url: "/modal/testData",
                    modalProps:{
                      onCancel: (res) => {
                        console.log(res, "2225881");
                      },
                    }
                  })
                }
              >
                测试数据
              </Button>
            </Space>
          )
        }
      />
      {items[activeIndex].Content}
    </>
  );
};

export default WorkingSteps;
