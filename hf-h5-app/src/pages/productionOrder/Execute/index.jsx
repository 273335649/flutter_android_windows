import React, { useState } from "react";
import { Tabs, Button, Space } from "antd";
import RightTop from "@/components/RightTop";
import { PlusOutlined } from "@ant-design/icons";
import usePopup from "@/hooks/usePopup";
import WorkingSteps from "./workingSteps";
import MaterialTable from "./materialTable";
import AccompanyTable from "./accompanyTable";
import AuxiliaryTable from "./auxiliaryTable";
import CubingTable from "./cubingTable";
import ToolTable from "./toolTable";
import WorkClothesTable from "./workClothesTable";
import { useModule } from "@/contexts/ModuleContext";
import { useRefresh } from "@/contexts/RefreshContext";
import { THINGS_TYPE, CATEGORY, TABLE_CODE } from "@/constants";
import styles from "./index.module.less";

const Execute = () => {
  const { sharedState } = useModule();
  console.log(sharedState, "share");
  const { triggerRefresh } = useRefresh();
  const [activeIndex, setActiveIndex] = useState("0");
  const { openPopup } = usePopup();

  const stepRequisitionBtn = ({ thingsType }) => (
    <div className={styles["add-button"]}>
      <Button
        icon={<PlusOutlined />}
        type="link"
        size="small"
        onClick={() => {
          openPopup({
            url: "/modal/stepRequisition",
            modalProps: {
              thingsType,
              vin: sharedState.vin,
              onCancel: (res) => {
                if (res?.type === "refresh") {
                  // 触发工装表格刷新
                  triggerRefresh(TABLE_CODE.WORK_CLOTHES_TABLE, { source: "stepRequisition" });
                }
              },
            },
          });
        }}
      >
        领用
      </Button>
    </div>
  );

  const items = [
    {
      key: "0",
      label: "工步",
      Content: <WorkingSteps />,
    },
    ...(sharedState.category !== CATEGORY.TESTING
      ? [
          {
            key: "1",
            label: "物料",
            Content: <MaterialTable thingsType={THINGS_TYPE.MATERIAL} />,
            AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.MATERIAL }),
          },
        ]
      : []),
    {
      key: "2",
      label: "工装",
      Content: <WorkClothesTable thingsType={THINGS_TYPE.FIXTURE} />,
      AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.FIXTURE }),
    },
    {
      key: "3",
      label: "工具",
      Content: <ToolTable thingsType={THINGS_TYPE.TOOL} />,
      AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.TOOL }),
    },
    {
      key: "4",
      label: "检具",
      Content: <CubingTable thingsType={THINGS_TYPE.GAUGE} />,
      AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.GAUGE }),
    },
    {
      key: "5",
      label: "辅料",
      Content: <AuxiliaryTable thingsType={THINGS_TYPE.AUXILIARY} />,
      AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.AUXILIARY }),
    },
    {
      key: "6",
      label: "陪试品",
      Content: <AccompanyTable thingsType={THINGS_TYPE.PVS} />,
      AddButton: stepRequisitionBtn({ thingsType: THINGS_TYPE.PVS }),
    },
  ];

  const onChange = (key) => {
    setActiveIndex(key);
  };

  const itemRecord = items.find((item) => item.key === activeIndex);

  return (
    <>
      <RightTop>
        <Tabs
          defaultActiveKey="0"
          indicator={{
            size: (origin) => origin - 20,
            align: "center",
          }}
          items={items}
          onChange={onChange}
          tabBarExtraContent={
            <Space style={{ marginRight: "16px" }}>
              {sharedState.category === CATEGORY.ACCESSORY_BOXING && <Button className="base-btn">打印标签</Button>}
              {sharedState.category === CATEGORY.PACKAGING && (
                <>
                  <Button className="base-btn">打印箱标</Button>
                  <Button className="base-btn">打印装箱清单</Button>
                </>
              )}
            </Space>
          }
        />
        {itemRecord.AddButton || <></>}
      </RightTop>
      {itemRecord.Content}
    </>
  );
};

export default Execute;
