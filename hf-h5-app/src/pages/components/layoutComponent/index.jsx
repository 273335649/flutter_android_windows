import React, { useCallback, useEffect } from "react";
import LeftInfo from "@/components/LeftInfo";
import { Flex } from "antd";
import { useModel } from "@umijs/max";
import { useModule } from "@/contexts/ModuleContext";
// 工单执行页面的layout
export const LayoutComponent = ({ children }) => {
  const { initialState } = useModel("@@initialState");
  const { navigateToModule, sharedRef, sharedState } = useModule();
  const toOrderList = useCallback(() => {
    sharedRef.current.vinSearchInput?.clear?.();
    navigateToModule("orderList");
  }, [navigateToModule, sharedRef]);

  useEffect(() => {
    toOrderList();
  }, [initialState.stationId]);

  // useEffect(() => {
  //   if (!sharedState.vin) {
  //     navigateToModule("orderList");
  //   }
  // }, [sharedState]);

  return (
    <Flex>
      <Flex vertical>
        <LeftInfo checkVin={true} bottomBtnReportShow={true} />
      </Flex>
      <div className="right-container">{children}</div>
    </Flex>
  );
};

export default LayoutComponent;
