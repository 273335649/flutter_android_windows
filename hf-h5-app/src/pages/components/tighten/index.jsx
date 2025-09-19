import React, { useEffect, useRef, useState } from "react";
import ImgMarkCanvas from "./component/ImgMarkCanvas";
// import bgtImg from "@/assets/bgt.jpg";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Flex } from "antd";
import useRequest from "@ahooksjs/use-request";
import { getStepSub } from "@/services/productionOrder";
import { useModel } from "@umijs/max";
import { useModule } from "@/contexts/ModuleContext";
import { useRefresh } from "@/contexts/RefreshContext";
import { TABLE_CODE } from "@/constants";

// 拧紧
const Tighten = () => {
  const { initialState } = useModel("@@initialState");
  const { sharedState, navigateToModule } = useModule();
  const { triggerRefresh } = useRefresh();
  const canvasRef = useRef();
  // let data = {
  //   bg: '{"OP010-2-120.JPG":"20250908163209502002.JPG"}',
  //   sortNo: null,
  //   status: "OK",
  //   finishStatus: "N",
  //   point: [
  //     {
  //       content: "将箱体组合从物料车上取下，放置在工作台上。",
  //       standard: null,
  //       torque: null,
  //       angle: null,
  //       x: 45.75,
  //       y: 51.297047,
  //       status: null,
  //       confirmStatus: null,
  //       id: null,
  //       stepLogId: null,
  //       type: "PROCESS",
  //       sortNo: 1,
  //       value1: null,
  //       value2: null,
  //       createBy: null,
  //       createTime: null,
  //       createName: null,
  //       value3: null,
  //       resultProcess: null,
  //       stationId: "1012088637438824448",
  //       stepId: "1963566162553999362",
  //       vin: "CA500-Ⅰ24M007",
  //       resultStatus: null,
  //     },
  //     {
  //       content: "将箱体组合从物料车上取下，放置在工作台上。",
  //       standard: null,
  //       torque: null,
  //       angle: null,
  //       x: 52,
  //       y: 73.13296,
  //       status: null,
  //       confirmStatus: null,
  //       id: null,
  //       stepLogId: null,
  //       type: "PROCESS",
  //       sortNo: 2,
  //       value1: null,
  //       value2: null,
  //       createBy: null,
  //       createTime: null,
  //       createName: null,
  //       value3: null,
  //       resultProcess: null,
  //       stationId: "1012088637438824448",
  //       stepId: "1963566162553999362",
  //       vin: "CA500-Ⅰ24M007",
  //       resultStatus: null,
  //     },
  //     {
  //       content: "将箱体组合从物料车上取下，放置在工作台上。",
  //       standard: null,
  //       torque: null,
  //       angle: null,
  //       x: 10.25,
  //       y: 41.938805,
  //       status: null,
  //       confirmStatus: null,
  //       id: null,
  //       stepLogId: null,
  //       type: "PROCESS",
  //       sortNo: 3,
  //       value1: null,
  //       value2: null,
  //       createBy: null,
  //       createTime: null,
  //       createName: null,
  //       value3: null,
  //       resultProcess: null,
  //       stationId: "1012088637438824448",
  //       stepId: "1963566162553999362",
  //       vin: "CA500-Ⅰ24M007",
  //       resultStatus: null,
  //     },
  //     {
  //       content: "将箱体组合从物料车上取下，放置在工作台上。",
  //       standard: null,
  //       torque: null,
  //       angle: null,
  //       x: 33.25,
  //       y: 26.341728,
  //       status: null,
  //       confirmStatus: null,
  //       id: null,
  //       stepLogId: null,
  //       type: "PROCESS",
  //       sortNo: 4,
  //       value1: null,
  //       value2: null,
  //       createBy: null,
  //       createTime: null,
  //       createName: null,
  //       value3: null,
  //       resultProcess: null,
  //       stationId: "1012088637438824448",
  //       stepId: "1963566162553999362",
  //       vin: "CA500-Ⅰ24M007",
  //       resultStatus: null,
  //     },
  //     {
  //       content: "将箱体组合从物料车上取下，放置在工作台上。",
  //       standard: null,
  //       torque: null,
  //       angle: null,
  //       x: 14.5,
  //       y: 70.36014,
  //       status: null,
  //       confirmStatus: null,
  //       id: null,
  //       stepLogId: null,
  //       type: "PROCESS",
  //       sortNo: 5,
  //       value1: null,
  //       value2: null,
  //       createBy: null,
  //       createTime: null,
  //       createName: null,
  //       value3: null,
  //       resultProcess: null,
  //       stationId: "1012088637438824448",
  //       stepId: "1963566162553999362",
  //       vin: "CA500-Ⅰ24M007",
  //       resultStatus: null,
  //     },
  //   ],
  // };
  const { data } = useRequest(getStepSub, {
    manual: false,
    defaultParams: [
      {
        vin: sharedState.vin,
        stepId: sharedState.stepId,
        stationId: initialState.stationId,
        lineId: initialState.lineId,
      },
    ],
    pollingInterval: 2000,
    formatResult: (res) => res?.data,
    onSuccess: (data) => {
      if (data.finishStatus === "Y") {
        // 全部执行完成
        navigateToModule("execute");
        triggerRefresh(TABLE_CODE.CURRENT_STEP, { source: "report" });
      }
    },
  });

  const columns = [
    // {
    //   header: "序号",
    //   size: 70,
    //   cell: ({ row }) => row.index + 1,
    // },
    {
      header: "序号",
      size: 80,
      accessorKey: "sortNo",
    },
    // {
    //   header: "类型",
    //   size: 80,
    //   accessorKey: "type",
    // },
    {
      header: "工步内容",
      size: 240,
      accessorKey: "content",
    },
    {
      header: "工艺标准",
      size: 120,
      accessorKey: "standard",
      tooltip: true,
    },
    {
      header: "拧紧扭矩",
      size: 120,
      accessorKey: "torque",
    },
    {
      header: "拧紧角度",
      size: 120,
      accessorKey: "angle",
    },
    {
      header: "拧紧状态",
      size: 120,
      accessorKey: "status",
      cell: ({ row }) => {
        return (
          <span style={{ color: row.original.status === "OK" ? "#1BFF49" : "#FF0000" }}>{row.original.status}</span>
        );
      },
    },
    {
      header: "二次检查",
      size: 120,
      accessorKey: "confirmStatus",
      cell: ({ row }) => {
        return (
          <span style={{ color: row.original.confirmStatus === "OK" ? "#1BFF49" : "#FF0000" }}>
            {row.original.confirmStatus}
          </span>
        );
      },
    },
    {
      header: "拧紧时间",
      size: 120,
      accessorKey: "tighteningTime",
    },
  ];

  return (
    <>
      <Flex justify="center">
        <ImgMarkCanvas
          ref={canvasRef}
          points={data?.point}
          activePoint={data?.sortNo}
          imgSrc={data?.bg}
          disabled={true}
        />
      </Flex>
      <TableContent>
        <TableComp columns={columns} dataSource={data?.point} />
      </TableContent>
    </>
  );
};

export default Tighten;
