import React, { useState, useCallback } from "react";
import { Tabs } from "antd";
import RightTop from "@/components/RightTop";
import PendingTable from "./pendingTable";
// import FinishTable from "./finishTable";
import { useModule } from "@/contexts/ModuleContext";
import Execute from "./Execute";
import Tighten from "@/pages/components/tighten";
import LayoutComponent from "@/pages/components/layoutComponent";
import commonStyle from "@/styles/common.less";

// 巡检/成品检验
const OrderList = () => {
  const { updateSharedState, sharedRef } = useModule();
  const [activeIndex, setActiveIndex] = useState("0");
  const onChange = (key) => {
    setActiveIndex(key);
  };

  const toExecute = useCallback(
    (record) => {
      updateSharedState({
        isInsp: true,
      });
      setTimeout(() => {
        sharedRef.current.vinSearchInput?.setValue?.(record?.vin);
      }, [0]);
    },
    [sharedRef],
  );
  const items = [
    {
      key: "0",
      label: "待检验",
      Content: (
        <PendingTable
          onExecuteClick={({ record }) => {
            toExecute(record);
          }}
        />
      ),
    },
    // {
    //   key: "1",
    //   label: "已完成",
    //   Content: (
    //     <FinishTable
    //       onExecuteClick={(e) => {
    //         console.log(e);
    //       }}
    //     />
    //   ),
    // },
  ];

  return (
    <>
      <RightTop title={"巡检/成品检验"}>
        <Tabs
          className={commonStyle["custom-tabs"]}
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
  const moduleMap = {
    orderList: <OrderList />,
    // repairList: <OrderList initActive={"1"} />,
    execute: <Execute />,
    tighten: <Tighten />,
    // ... 更多模块
  };
  return <LayoutComponent>{moduleMap[currentModule || "orderList"] || <></>}</LayoutComponent>;
};
