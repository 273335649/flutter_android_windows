import React from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Button, Flex, Image } from "antd";
import InputFormComponent from "@/components/InputFormComponent";
import styles from "./index.module.less";

// 工步

const WorkStepsTable = () => {
  const columns = [
    {
      header: "工步编号",
      size: 150,
      accessorKey: "sequenceNumber",
    },
    // {
    //   header: "装配顺序",
    //   size: 150,
    //   accessorKey: "repairOrderNumber",
    // },
    {
      header: "类型",
      size: 150,
      accessorKey: "productionOrderNumber",
    },
    {
      header: "工步名称",
      size: 150,
      accessorKey: "sapOrderNumber",
    },
    {
      header: "工步内容",
      size: 150,
      accessorKey: "model",
    },
    {
      header: "工艺标准",
      size: 150,
      accessorKey: "statusCode",
      tooltip: true,
    },
    {
      header: "录入",
      size: 300,
      accessorKey: "plannedTime",
      cell: ({ row }) => (
        <InputFormComponent
          key={`${row.id}-${cell.id}`}
          opType={row.original.opType}
          name="resultValue"
          inputProps={{
            className: styles.input,
            style: { width: 254, maxWidth: "80%", height: 50 },
          }}
        />
      ),
    },
    {
      header: "合格",
      size: 200,
      accessorKey: "jobProductionQuantity",
      cell: () => (
        <Button className={`${styles.btn} ${styles.qualified}`} type="primary">
          OK
        </Button>
      ),
    },
    {
      header: "不合格",
      size: 200,
      accessorKey: "plannedQuantity",
      cell: () => <Button className={`${styles.btn} ${styles.unqualified}`}>NG</Button>,
    },
  ];

  // const columns2 = [
  //   {
  //     header: "物料编码",
  //     size: 134,
  //     accessorKey: "sequenceNumber",
  //   },
  //   {
  //     header: "物料名称",
  //     size: 196,
  //     accessorKey: "repairOrderNumber",
  //   },
  //   {
  //     header: "校验",
  //     size: 178,
  //     accessorKey: "productionOrderNumber",
  //     cell: () => (
  //       <Input
  //         className={styles.input}
  //         style={{ width: 120, height: 35.5 }}
  //         size="small"
  //         allowClear={{
  //           clearIcon: <Image preview={false} src={require("@/assets/chevron-right.png")} />,
  //         }}
  //         prefix={<Image preview={false} src={require("@/assets/chevron-right.png")} />}
  //       />
  //     ),
  //   },
  // ];

  // const columns3 = [
  //   {
  //     header: "物料编码",
  //     size: 188,
  //     accessorKey: "sequenceNumber",
  //   },
  //   {
  //     header: "物料名称",
  //     size: 188,
  //     accessorKey: "repairOrderNumber",
  //   },
  //   {
  //     header: "数量",
  //     size: 64,
  //     accessorKey: "productionOrderNumber",
  //   },
  //   {
  //     header: "校验",
  //     size: 64,
  //     accessorKey: "productionOrderNumber",
  //   },
  // ];

  // const columns4 = [
  //   {
  //     header: "数量",
  //     size: 64,
  //     accessorKey: "sequenceNumber",
  //   },
  //   {
  //     header: "批次/序列号",
  //     size: 256,
  //     accessorKey: "productionOrderNumber",
  //     cell: () => (
  //       <Input
  //         className={styles.input}
  //         style={{ width: 200, height: 35.5 }}
  //         size="small"
  //         allowClear={{
  //           clearIcon: <Image preview={false} src={require("@/assets/chevron-right.png")} />,
  //         }}
  //         prefix={<Image preview={false} src={require("@/assets/chevron-right.png")} />}
  //       />
  //     ),
  //   },
  // ];

  const dataSource = Array.from({ length: 3 }).map((_, i) => ({
    key: i,
    sequenceNumber: `${i + 1}`,
    repairOrderNumber: `${1000 + i}`,
    productionOrderNumber: `${1 + i}`,
    sapOrderNumber: `SAP${3000 + i}`,
    model: `Model-${i % 5}`,
    statusCode: `Status-${i % 3}`,
    plannedTime: `2023-0${(i % 9) + 1}-1${(i % 9) + 1} 09:00:00`,
    jobProductionQuantity: `${100 + i}`,
    plannedQuantity: `${200 + i}`,
    jobQuantity: `${300 + i}`,
    reportedQuantity: `${400 + i}`,
  }));

  const TableTitle = ({ title }) => {
    return (
      <Flex align="center" className={styles["table-header"]}>
        <div className={styles["left-icon"]}></div>
        {title}
      </Flex>
    );
  };

  return (
    <>
      <Flex className={styles["execute-content"]}>
        <TableContent style={{ margin: "10px 12px 0px 12px" }}>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </Flex>
    </>
  );
};

export default WorkStepsTable;
