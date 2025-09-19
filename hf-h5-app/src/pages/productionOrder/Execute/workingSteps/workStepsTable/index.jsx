import React from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Button, Flex, Form } from "antd";
import VerifyInput from "@/pages/components/verifyInput";
import { useCommon } from "@/hooks/useCommon";
import { OPERATION_RESULT, STEP_OPERATE_TYPE, CATEGORY, THINGS_TYPE, TABLE_CODE } from "@/constants";
import { useModule } from "@/contexts/ModuleContext";
import { useRefresh } from "@/contexts/RefreshContext";
import useIntoVinStep from "@/hooks/useIntoVinStep";
import InputFormComponent from "@/components/InputFormComponent";
import styles from "./index.module.less";
// 工步

const WorkStepsTable = ({ stepLoading, stepData }) => {
  const { sharedState } = useModule();
  const { triggerRefresh } = useRefresh();
  const { onStepFinish } = useIntoVinStep();
  const { isInspection } = useCommon();
  const [form] = Form.useForm();
  const onFinish = async (values) => {
    let bool = await onStepFinish(values, stepData);
    bool && form?.resetFields();
  };
  console.log(sharedState.isInsp, "isInsp");
  const columns = [
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
      header: "类型",
      size: 100,
      accessorKey: "opTypeInput",
      cell: ({ row }) => {
        return STEP_OPERATE_TYPE[row.original.opType]?.name || "-";
      },
    },
    {
      header: "工步名称",
      size: 150,
      accessorKey: "name",
    },
    {
      header: "工步内容",
      accessorKey: "content",
      tooltip: true,
    },
    {
      header: "工艺标准",
      size: 120,
      accessorKey: "standard",
      tooltip: true,
    },
    {
      header: "录入",
      size: 300,
      accessorKey: "inputComponent",
      cell: ({ row, cell }) => {
        return (
          <>
            <InputFormComponent
              key={`${row.id}-${cell.id}`}
              opType={row.original.opType}
              name="resultValue"
              inputProps={{
                onChange: async (val) => {
                  // 解析 inspectionStd 字符串，例如 "1~10" 格式
                  const bool = await isInspection({ row, val });
                  if (bool) {
                    form.setFieldValue("resultStatus", bool);
                  }
                },
                className: styles.input,
                style: { width: 254, maxWidth: "80%", height: 50 },
              }}
            />
          </>
        );
      },
    },
    {
      header: "合格",
      size: 140,
      accessorKey: "jobProductionQuantity",
      cell: () => (
        <Button
          className={`${styles.btn} ${styles.qualified}`}
          type="primary"
          onClick={() => {
            form.setFieldsValue({
              resultStatus: OPERATION_RESULT.OK,
            });
            form.submit();
          }}
        >
          OK
        </Button>
      ),
    },
    {
      header: "不合格",
      size: 140,
      accessorKey: "plannedQuantity",
      cell: () => (
        <Button
          className={`${styles.btn} ${styles.unqualified}`}
          onClick={() => {
            form.setFieldsValue({
              resultStatus: OPERATION_RESULT.NG,
            });
            form.submit();
          }}
        >
          NG
        </Button>
      ),
    },
  ];

  const columns2 = [
    {
      header: "编码",
      size: 134,
      accessorKey: "thingsCode",
    },
    {
      header: "名称",
      size: 196,
      accessorKey: "thingsName",
    },
    {
      header: "校验",
      size: 178,
      accessorKey: "thingsNo",
      cell: (info) => (
        <VerifyInput
          isVerified={info.row.original.isVerified}
          thingsType={info.row.original.thingsType}
          reqId={info.row.original.vinStepThingsId || info.row.original.id}
        />
      ),
    },
  ];

  const columns3 = [
    {
      header: "编码",
      size: 156,
      accessorKey: "thingsCode",
    },
    {
      header: "名称",
      size: 156,
      accessorKey: "thingsName",
    },
    {
      header: "数量",
      size: 100,
      accessorKey: "stdQty",
    },
    {
      header: "校验",
      size: 150,
      accessorKey: "thingsNo",
      cell: (info) => (
        <VerifyInput
          isVerified={info.row.original.isVerified}
          thingsType={info.row.original.thingsType}
          reqId={info.row.original.vinStepThingsId || info.row.original.id}
          onSuccess={() => {
            triggerRefresh(TABLE_CODE.CURRENT_STEP, { source: "verify" });
          }}
        />
      ),
    },
  ];

  const columns4 = [
    {
      header: "箱号",
      size: 64,
      accessorKey: "boxSerialNo",
      cell: (info) => `${info.row.original.boxSerialNo}/${info.row.original.subBoxQty}`,
    },
    {
      header: "箱标码",
      size: 256,
      accessorKey: "boxCode",
      cell: (info) => (
        <VerifyInput
          isVerified={info.getValue()}
          thingsType={THINGS_TYPE.BOX_CODE}
          data={{ vin: sharedState.vin, boxSerialNo: info.row.original.boxSerialNo }}
        />
      ),
    },
  ];

  const TableTitle = ({ title }) => {
    return (
      <Flex align="center" className={styles["table-header"]}>
        <div className={styles["left-icon"]}></div>
        {title}
      </Flex>
    );
  };

  let isPacking = sharedState.category === CATEGORY.PACKAGING;

  let tables = [
    {
      title: "工具/工装/检具",
      columns: columns2,
      dataSource: stepData?.fixtures,
      width: isPacking ? 516 : 683,
      show: true,
    },
    {
      title: "辅料/陪试品",
      columns: columns3,
      dataSource: stepData?.auxiliaries,
      width: isPacking ? 516 : 683,
      show: true,
    },
    {
      title: "箱号",
      columns: columns4,
      dataSource: stepData?.boxes,
      width: 324,
      show: isPacking,
    },
  ];
  let executeClassName =
    stepData?.hasInspStep === "Y"
      ? `${styles["execute-content"]} ${styles["execute-content-xj"]}`
      : `${styles["execute-content"]}`;
  return (
    <>
      <Form form={form} onFinish={onFinish}>
        <Form.Item noStyle hidden name={"resultStatus"} />
        <Flex className={executeClassName}>
          <TableContent style={{ margin: "10px 12px 0px 12px" }}>
            <TableComp columns={columns} dataSource={[stepData || {}]} loading={stepLoading} />
          </TableContent>
        </Flex>
      </Form>
      {!sharedState.isInsp && (
        <Flex className={styles["order-content"]}>
          {tables.map(({ columns, dataSource, title, width, show }, i) => (
            <React.Fragment key={i}>
              {show && (
                <Flex vertical>
                  <TableTitle title={title} />
                  <TableContent style={{ margin: 0, width }}>
                    <TableComp columns={columns} dataSource={dataSource} loading={stepLoading} />
                  </TableContent>
                </Flex>
              )}
              {i < tables.length - 1 && <div style={{ width: 10 }}></div>}
            </React.Fragment>
          ))}
        </Flex>
      )}
    </>
  );
};

export default WorkStepsTable;
