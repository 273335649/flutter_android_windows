import React, { useEffect } from "react";
import { Button } from "antd";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import useRequest from "@ahooksjs/use-request";
import { listTodayAndUndoStationOrders } from "@/services/productionOrder";
import { useModel } from "@umijs/max";
import dayjs from "dayjs";
// import { BIZ_TYPE } from "@/constants";

// 工单
const OrderTable = ({ onExecuteClick }) => {
  const { initialState } = useModel("@@initialState");

  const onDetailClick = (info) => {
    console.log("明细按钮点击，记录：", info);
    onExecuteClick(info.row.original);
  };

  const onCallMaterialClick = (info) => {
    console.log("呼叫物料按钮点击，记录：", info);
  };

  const columns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "index",
      fixed: "left",
    },
    {
      header: "岗位计划号",
      size: 150,
      accessorKey: "scheduleNo",
    },
    {
      header: "生产订单号",
      size: 150,
      accessorKey: "orderNo",
      tooltip: true,
    },
    {
      header: "SAP订单号",
      size: 150,
      accessorKey: "scOrderNo",
    },
    {
      header: "机型",
      size: 150,
      accessorKey: "jx",
    },
    {
      header: "状态码",
      size: 150,
      accessorKey: "ztbm",
    },
    {
      header: "计划时间",
      size: 300,
      accessorKey: "plannedTime",
      cell: (info) => <div>{`${dayjs(info.row.original.startTime)?.format("YYYY-MM-DD") || ""}`}</div>,
    },
    // {
    //   header: "岗位生产数量",
    //   size: 200,
    //   accessorKey: "inQty",
    // },
    {
      header: "计划数量",
      size: 200,
      accessorKey: "scheduleQty",
    },
    {
      header: "报工数量",
      size: 200,
      accessorKey: "okQty",
    },
    {
      header: "操作",
      size: 186,
      fixed: "right",
      fixed: "right",
      accessorKey: "actions",
      cell: (info) => (
        <>
          <div style={{ display: "flex", gap: "8px" }}>
            <Button type="link" size="small" onClick={() => onDetailClick(info)}>
              明细
            </Button>
            <Button type="link" size="small" style={{ color: "#FF4141" }} onClick={() => onCallMaterialClick(info)}>
              呼叫物料
            </Button>
          </div>
        </>
      ),
    },
  ];

  const {
    data: dataSource = [],
    run,
    loading,
  } = useRequest(listTodayAndUndoStationOrders, {
    manual: true,
    formatResult: (res) => res.data,
  });

  useEffect(() => {
    run({
      lineId: initialState.lineId,
      stationId: initialState.stationId,
    });
  }, [initialState.stationId]);

  return (
    <TableContent>
      <TableComp columns={columns} dataSource={dataSource?.map((v, i) => ({ ...v, index: i + 1 }))} loading={loading} />
    </TableContent>
  );
};

export default OrderTable;
