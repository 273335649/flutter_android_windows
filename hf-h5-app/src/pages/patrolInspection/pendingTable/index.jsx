import React, { useEffect } from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { listInspVins } from "@/services/patrolInspection";
import useRequest from "@ahooksjs/use-request";
import { STEP_TYPE_NAME } from "@/constants";
import { useModel } from "umi";

// 待检验列表
const PendingTable = ({ onExecuteClick }) => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null, stationId = null } = initialState;
  const { data: dataSource, run: runListInspVins } = useRequest(listInspVins, {
    manual: true,
    formatResult: (res) => res?.data || res,
  });

  useEffect(() => {
    runListInspVins({
      lineId: lineId,
      stationId: stationId,
    });
  }, [lineId, stationId]);

  const onDetailClick = (record) => {
    console.log("明细按钮点击，记录：", record);
    onExecuteClick({
      visible: true,
      record,
    });
  };

  const columns = [
    {
      header: "序号",
      size: 70,
      cell: ({ row }) => row.index + 1,
    },
    {
      header: "巡检类型",
      size: 150,
      accessorKey: "INSE_FINAL",
      cell: (info) => STEP_TYPE_NAME[info.getValue() || "INSP"],
    },
    {
      header: "巡检状态",
      size: 150,
      accessorKey: "num2",
      cell: () => <span>巡检中</span>,
    },
    // {
    //   header: "状态码",
    //   size: 150,
    //   accessorKey: "materialCode",
    // },
    // {
    //   header: "机型",
    //   size: 150,
    //   accessorKey: "model",
    // },
    // {
    //   header: "SAP订单号",
    //   size: 150,
    //   accessorKey: "scOrderNo",
    // },
    {
      header: "机号",
      size: 300,
      accessorKey: "vin",
    },
    {
      header: "岗位计划号",
      size: 200,
      accessorKey: "orderNo",
    },
    {
      header: "应检项目",
      size: 200,
      accessorKey: "inspStepCount",
    },
    {
      header: "待检项目",
      size: 200,
      accessorKey: "inspStepUndoCount",
    },
    {
      header: "已检项目",
      size: 200,
      accessorKey: "inspStepLogCount",
    },
    // {
    //   header: "操作",
    //   size: 150,
    //   accessorKey: "operation",
    //   fixed: "right",
    //   cell: (info) => (
    //     <Button type="link" onClick={() => onDetailClick(info)}>
    //       明细
    //     </Button>
    //   ),
    // },
  ];

  return (
    <TableContent>
      <TableComp columns={columns} dataSource={dataSource} isItemClick={(record) => onDetailClick(record)} />
    </TableContent>
  );
};

export default PendingTable;
