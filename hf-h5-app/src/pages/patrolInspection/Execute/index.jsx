import React, { useState } from "react";
import { Tabs, Button } from "antd";
import { PlusOutlined } from "@ant-design/icons";
import RightTop from "@/components/RightTop";
import WorkingSteps from "./workingSteps";
import CubingTable from "@/pages/productionOrder/Execute/cubingTable";
import ToolTable from "@/pages/productionOrder/Execute/toolTable";
import WorkClothesTable from "@/pages/productionOrder/Execute/workClothesTable";
import { useModule } from "@/contexts/ModuleContext";
import { useRefresh } from "@/contexts/RefreshContext";
import { THINGS_TYPE, TABLE_CODE } from "@/constants/index";
import usePopup from "@/hooks/usePopup";
import styles from "./index.module.less";
// 巡检/成品检验工步执行
const Execute = () => {
  const { sharedState } = useModule();
  const { triggerRefresh } = useRefresh();
  const { openPopup } = usePopup();
  const [activeIndex, setActiveIndex] = useState("0");

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
                console.log(res);
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
    // {
    //   key: "1",
    //   label: "物料",
    //   Content: <MaterialTable />,
    // },
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
    // {
    //   key: "5",
    //   label: "辅料",
    //   Content: <AuxiliaryTable />,
    // },
    // {
    //   key: "6",
    //   label: "陪试品",
    //   Content: <AccompanyTable />,
    // },
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
          // tabBarExtraContent={
          //   <Space style={{ marginRight: "16px" }}>
          //     <Button className="base-btn">打印标签</Button>
          //     <Button className="base-btn">打印箱标</Button>
          //     <Button className="base-btn">打印装箱清单</Button>
          //   </Space>
          // }
        />
        {itemRecord.AddButton || <></>}
      </RightTop>
      {itemRecord.Content}
    </>
  );
};

export default Execute;
