import React from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Button, Flex } from "antd";
// 工步记录
const WorkStepsRecordTable = () => {
  const onDetailClick = (info) => {
    console.log(info);
  };
  const columns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "sequenceNumber",
    },
    {
      header: "工步编号",
      size: 120,
      accessorKey: "stepCode",
    },
    {
      header: "装配顺序",
      size: 100,
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
      accessorKey: "stepContent",
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
      accessorKey: "inspectionResult",
    },
    {
      header: "检测值",
      size: 100,
      accessorKey: "inspectionValue",
    },
    {
      header: "报工人",
      size: 100,
      accessorKey: "reportedBy",
    },
    {
      header: "报工时间",
      size: 150,
      accessorKey: "reportedTime",
    },
  ];

  const dataSource = Array.from({ length: 100 }).map((_, i) => ({
    key: i,
    sequenceNumber: `${i + 1}`,
    stepCode: `STEP-${1000 + i}`,
    assemblySequence: `${(i % 10) + 1}`,
    stepName: `工步-${(i % 5) + 1}`,
    stepContent: `工步内容描述 ${i + 1}`,
    processStandard: `工艺标准 ${(i % 3) + 1}`,
    materialCode: `MAT-${10000 + i}`,
    inspectionResult: i % 2 === 0 ? "合格" : "不合格",
    inspectionValue: `${(i % 10) + 1}.${i % 10}`,
    reportedBy: `操作员-${(i % 5) + 1}`,
    reportedTime: `2023-0${(i % 9) + 1}-1${(i % 9) + 1} ${i % 24}:${i % 60 < 10 ? "0" + (i % 60) : i % 60}:00`,
  }));
  return (
    <Flex style={{ height: "500px" }}>
      <TableContent style={{ margin: "10px 12px 0px 12px" }}>
        <TableComp columns={columns} dataSource={dataSource} />
      </TableContent>
    </Flex>
  );
};

export default WorkStepsRecordTable;
