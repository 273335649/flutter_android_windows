import React, { useEffect } from "react";
import { Button } from "antd";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { listInspVins } from "@/services/patrolInspection";
import useRequest from "@ahooksjs/use-request";
import { STEP_TYPE_NAME } from "@/constants";
import { useModel } from "umi";

//   {
//     "id": "", //主键ID
//     "vin": "", //机号
//     "lineId": "", //产线ID
//     "stationId": "", //当前岗位ID
//     "stationWorkOrderId": "", //当前岗位作业单ID MES_PROD_STATION_ORDER
//     "stepId": "", //工步ID
//     "parentStepId": "", //巡检/成品检验工步时，父级工步ID
//     "stepLogId": "", //工步作业记录ID
//     "isRework": 0, //是否正在返修：0=否，1=是
//     "parentStepLogId": "", //巡检/成品检验工步时，父级工步作业记录ID
//     "stationLogId": "", //岗位作业记录ID
//     /**
//      * 装配订单号(岗位计划号)
//      * 装配订单号
//      */
//     "orderNo": "",
//     "zpjhh": "", //排产计划号
//     "scddlx": "", //生产订单类型
//     "jx": "", //机型
//     "scOrderNo": "", //生产订单号
//     "materialCode": "", //物品编码
//     "eqptId": "", //设备ID
//     "cartCode": "", //工装车编码
//     "category": "", //岗位类型,部装=SUB_ASSEMBLY,装配=FINAL_ASSEMBLY,测试=TESTING,返工=REWORK,附件分箱=ACCESSORY_BOXING,包装=PACKAGING
//     "packing": "", //是否装箱 N=否,Y=是
//     /**
//      * STEP = 进入工步，EQPT_CHECK=进入设备点检，REPAIR=进入返修工单，TECH_NOTICE=技术通知，MUTUAL_INSPECT=岗位互检
//      * 返回结果代码
//      */
//     "resultCode": "",
//     "resultMsg": "", //返回消息
//     "firstVin": 0, //是否首件，N=否, Y=是
//     "ilsOk": 0, //互锁是否报工，N=否, Y=是
//     "stationName": "", //岗位名称
//     "stationCode": "" //岗位编码
// }
// 待检验列表
const PendingTable = ({ onExecuteClick }) => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null, stationId = null } = initialState;
  const { data: dataSource, run: runListInspVins } = useRequest(listInspVins, {
    manual: true,
    formatResult: (res) => res?.data || res,
  });

  useEffect(() => {
    run({
      lineId: lineId,
      stationId: stationId,
    });
  }, [lineId, stationId]);

  const onDetailClick = (info) => {
    console.log("明细按钮点击，记录：", info);
    onExecuteClick({
      visible: true,
      record: info.row.original,
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
    {
      header: "状态码",
      size: 150,
      accessorKey: "materialCode",
    },
    {
      header: "机型",
      size: 150,
      accessorKey: "model",
    },
    {
      header: "SAP订单号",
      size: 150,
      accessorKey: "scOrderNo",
    },
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
    // {
    //   header: "应检项目",
    //   size: 200,
    //   accessorKey: "num3",
    // },
    // {
    //   header: "待检项目",
    //   size: 200,
    //   accessorKey: "num4",
    // },
    // {
    //   header: "已检项目",
    //   size: 200,
    //   accessorKey: "num5",
    // },
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
      <TableComp columns={columns} dataSource={dataSource} />
    </TableContent>
  );
};

export default PendingTable;
