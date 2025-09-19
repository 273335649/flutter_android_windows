import React from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Flex, message } from "antd";
import { useModel } from "@umijs/max";
import { listStationVinStepLog } from "@/services/stepRequisition";
import { useModule } from "@/contexts/ModuleContext";
import useRequest from "@ahooksjs/use-request";
// 工步记录
const WorkStepsRecordTable = () => {
  const { initialState } = useModel("@@initialState");
  const { sharedState } = useModule();

  const { data: dataSource, loading } = useRequest(listStationVinStepLog, {
    manual: false,
    defaultParams: [
      {
        vin: sharedState.vin,
        stationId: initialState.stationId,
        lineId: initialState.lineId,
      },
    ],
    formatResult: (res) => res?.data || res,
    onSuccess: (res) => (res.message ? message.info(res.message) : null),
  });
  const columns = [
    // {
    //   header: "序号",
    //   size: 70,
    //   accessorKey: "sequenceNumber",
    // },
    {
      header: "工步编号",
      size: 120,
      accessorKey: "stepNo",
    },
    {
      header: "装配顺序",
      size: 120,
      accessorKey: "sortNo",
    },
    {
      header: "工步名称",
      size: 150,
      accessorKey: "stepName",
    },
    {
      header: "工步内容",
      size: 200,
      accessorKey: "content",
    },
    {
      header: "工艺标准",
      size: 200,
      accessorKey: "standard",
      tooltip: true,
    },
    {
      header: "物料编码",
      size: 150,
      accessorKey: "materialCode",
    },
    {
      header: "检测结果",
      size: 120,
      accessorKey: "status",
    },
    {
      header: "检测值",
      size: 100,
      accessorKey: "inspectionValue",
    },
    {
      header: "报工人",
      size: 100,
      accessorKey: "reportUserName",
    },
    {
      header: "报工时间",
      size: 150,
      accessorKey: "reportTime",
    },
  ];

  return (
    <Flex style={{ height: "500px" }}>
      <TableContent style={{ margin: "10px 12px 0px 12px" }}>
        <TableComp loading={loading} columns={columns} dataSource={dataSource} />
      </TableContent>
    </Flex>
  );
};

export default WorkStepsRecordTable;
