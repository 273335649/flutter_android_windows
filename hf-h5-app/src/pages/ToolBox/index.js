import React from "react";
import { Flex } from "antd";
import LeftInfo from "@/components/LeftInfo";
import RightTop from "@/components/RightTop";
import usePopup from "@/hooks/usePopup";
import { useModule } from "@/contexts/ModuleContext";
import "./index.less";

export default () => {
  const { openPopup } = usePopup();
  const { sharedState } = useModule();

  const toolList = [
    {
      name: "发动机上线绑定",
      onClick: () => {
        openPopup({
          url: "/modal/engineBindModal",
        });
      },
    },
    {
      name: "半成品下线",
      onClick: () => {
        console.log(sharedState, "sharedState");
        if (sharedState.carNo && sharedState.vin && sharedState.scheduleLogId) {
          openPopup({
            url: "/modal/productOfflineModal",
            modalProps: {
              carNo: sharedState.carNo,
              vin: sharedState.vin,
              scheduleLogId: sharedState.scheduleLogId,
            },
          });
        } else {
          openPopup({
            url: "/modal/baseModal",
            modalProps: {
              content: "请先绑定机号！",
            },
          });
        }
      },
    },
    {
      name: "核心机上线",
    },
    {
      name: "AGV任务信息",
    },
    {
      name: "AGV退空料车",
    },
    {
      name: "派送发动机",
    },
    {
      name: "呼叫工装车",
    },
    {
      name: "退发动机到缓存区",
    },
    {
      name: "召回缓存区发动机",
    },
    {
      name: "批量报工",
    },
    {
      name: "软键盘",
    },
    {
      name: "部装件报废",
    },
  ];
  return (
    <Flex gap={12}>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"工具箱"} />
        <div className="tool-box">
          {toolList.map((item, index) => (
            <div
              className="tool-item"
              key={index}
              onClick={() => {
                item.onClick?.();
              }}
            >
              <img src={require(`@/assets/tool-img${index}.png`)} alt="" />
              <div>{item.name}</div>
            </div>
          ))}
        </div>
      </div>
    </Flex>
  );
};
