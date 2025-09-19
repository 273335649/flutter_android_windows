import React, { useEffect } from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Button } from "antd";
import useRequest from "@ahooksjs/use-request";
import { listRepairOrders } from "@/services/productionOrder/index";
import { useModel } from "@umijs/max";
import dayjs from "dayjs";
// import { BIZ_TYPE } from "@/constants";
// 返修工单
const RepairTable = ({ onExecuteClick }) => {
  const { initialState } = useModel("@@initialState");
  const onDetailClick = (info) => {
    console.log("明细按钮点击，记录：", info);
    onExecuteClick(info.row.original);
  };

  const columns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "index",
      fixed: "left",
    },
    {
      header: "返修单号",
      size: 150,
      accessorKey: "no",
    },
    {
      header: "生产订单号",
      size: 150,
      accessorKey: "orderNo",
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
      cell: (info) => <div>{`${dayjs(info.row.original.startDay)?.format("YYYY-MM-DD") || ""}`}</div>,
    },
    // {
    //   header: "岗位生产数量",
    //   size: 200,
    //   accessorKey: "inQty",
    // },
    {
      header: "计划数量",
      size: 200,
      accessorKey: "planQty",
    },
    // {
    //   header: "岗位数量",
    //   size: 200,
    //   accessorKey: "okQty",
    // },
    {
      header: "报工数量",
      size: 200,
      accessorKey: "reportedQuantity",
    },
    {
      header: "操作",
      size: 186,
      fixed: "right",
      cell: (info) => (
        <div style={{ display: "flex", gap: "8px" }}>
          <Button type="link" size="small" onClick={() => onDetailClick(info)}>
            明细
          </Button>
        </div>
      ),
    },
  ];

  const {
    data: dataSource = [],
    run,
    loading,
  } = useRequest(listRepairOrders, {
    manual: true,
    formatResult: (res) => res?.data || res,
  });

  useEffect(() => {
    run({
      lineId: initialState.lineId,
      stationId: initialState.stationId,
    });
  }, []);

  return (
    <TableContent>
      <TableComp columns={columns} dataSource={dataSource?.map((v, i) => ({ ...v, index: i + 1 }))} loading={loading} />
    </TableContent>
  );
};

export default RepairTable;
