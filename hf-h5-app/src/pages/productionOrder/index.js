import React, { useCallback, useEffect, useState } from "react";
import { Tabs } from "antd";
import RightTop from "@/components/RightTop";
import OrderTable from "./orderTable";
import RepairTable from "./repairTable";
import Execute from "./Execute";
import Tighten from "@/pages/components/tighten";
import LayoutComponent from "@/pages/components/layoutComponent";
import usePopup from "@/hooks/usePopup";
import { WORK_ORDER_TYPE } from "@/constants";
import { useModule } from "@/contexts/ModuleContext";
import { useModel } from "@umijs/max";
import commonStyle from "@/styles/common.less";

// 工单列表

const defaultActiveIndex = "0";

const OrderList = ({ initActive }) => {
  const { initialState } = useModel("@@initialState");
  const { openPopup } = usePopup();
  const { sharedRef } = useModule();
  const [activeIndex, setActiveIndex] = useState(defaultActiveIndex);

  const onChange = (key) => {
    setActiveIndex(key);
  };

  const toExecute = useCallback(
    (record, type) => {
      // navigateToModule("execute");
      // return;
      openPopup({
        url: "/modal/vinsSelectModal",
        modalProps: {
          workOrderId: record.id,
          scheduleLogId: record.scheduleLogId,
          stationId: initialState.stationId,
          type,
          onCancel: (res) => {
            sharedRef.current.vinSearchInput?.setValue?.(res?.vin);
          },
        },
      });
    },
    [sharedRef],
  );

  const items = [
    {
      key: "0",
      label: "工单",
      Content: (
        <OrderTable
          onExecuteClick={(record) => {
            toExecute(record, WORK_ORDER_TYPE.NORMAL);
          }}
        />
      ),
    },
    {
      key: "1",
      label: "返修工单",
      Content: (
        <RepairTable
          onExecuteClick={(record) => {
            toExecute(record, WORK_ORDER_TYPE.REPAIR);
          }}
        />
      ),
    },
  ];

  useEffect(() => {
    onChange(initActive || defaultActiveIndex);
  }, [initActive]);

  return (
    <>
      <RightTop>
        <Tabs
          className={commonStyle["custom-tabs"]}
          activeKey={activeIndex}
          defaultActiveKey="0"
          indicator={{
            size: (origin) => origin - 20,
            align: "center",
          }}
          items={items}
          onChange={onChange}
        />
      </RightTop>
      {items[activeIndex].Content}
    </>
  );
};

export default () => {
  const { currentModule } = useModule();
  // console.log(currentModule || "orderList", "currentModule");
  const moduleMap = {
    orderList: <OrderList />,
    repairList: <OrderList initActive={"1"} />,
    execute: <Execute />,
    tighten: <Tighten />,
    // ... 更多模块
  };
  return <LayoutComponent>{moduleMap[currentModule || "orderList"] || <></>}</LayoutComponent>;
};
