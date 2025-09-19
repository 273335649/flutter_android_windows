import React, { useCallback, useEffect, useState } from "react";
import { Modal, Row, Col, Button, Flex, Image, Space, Form, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import common from "../common.less";
import useRequest from "@ahooksjs/use-request";
import { OPERATION_RESULT, STEP_OPERATE_TYPE } from "@/constants";
import { getMutualInspectList, executeMutualInspect } from "@/services/productionOrder";
import LoadingImage from "@/components/LoadingImage";
import InputFormComponent from "@/components/InputFormComponent";
import useIntoVinStep from "@/hooks/useIntoVinStep";

const CheckBtn = ({ row, form, activeBgColor, className, checkValue, children, ...resetProps }) => {
  const watchResultStatus = Form.useWatch(["items", row.index, "inspectResult"], form);
  return (
    <Button
      className={`${common.btn} ${className}`}
      style={watchResultStatus === checkValue ? { background: activeBgColor } : {}}
      onClick={async () => {
        form.setFieldValue(["items", row.index, "inspectResult"], checkValue);
      }}
      {...resetProps}
    >
      {children}
    </Button>
  );
};

// 执行互检 岗位互检
const CrossCheckModal = () => {
  const [form] = Form.useForm();

  const { openRepairPopup } = useIntoVinStep();

  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();
  let reqId = searchParams.get("reqId");
  let vin = searchParams.get("vin");

  const [isModalOpen, setIsModalOpen] = useState(true);

  const { data, run: check } = useRequest(executeMutualInspect, {
    manual: true,
  });

  const { data: dataSource, run: getData } = useRequest(getMutualInspectList, {
    manual: true,
    formatResult: (res) => res.data,
  });

  useEffect(() => {
    if (reqId && vin) {
      getData({ reqId, vin });
    }
  }, [reqId, vin]);

  const handleOk = useCallback(async () => {
    let values = await form.validateFields();
    let operateType = OPERATION_RESULT.OK;
    const hasNG = values.items.some((item) => item.inspectResult === OPERATION_RESULT.NG);
    let res = {};
    if (hasNG) {
      res = await openRepairPopup();
      operateType = res?.resultStatus === OPERATION_RESULT.PASS_OK ? OPERATION_RESULT.OK : OPERATION_RESULT.NG;
    }
    let data = {
      // reqId,
      vin,
      ...res,
      operateType,
      contentList: values.items.map((it) => ({
        ...it,
        faultFile: JSON.stringify(it?.faultFile),
      })),
    };
    check(data).then((res) => {
      if (res.success) {
        setIsModalOpen(false);
        // 1. 通知Flutter关闭全屏容器
        closePopup();
      } else {
        message.info(res.message);
      }
    });
  }, [vin]);

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };
  const columns = [
    {
      header: "检查事项",
      accessorKey: "item",
      size: 193,
    },
    {
      header: "描述",
      accessorKey: "description",
      size: 330,
    },
    {
      header: "标准图片",
      accessorKey: "standardImage",
      size: 128,
      cell: ({ row }) => (
        <Flex justify={"center"} style={{ textIndent: 0 }}>
          <LoadingImage width={100} height={50} src={row.original.standardImage} />
        </Flex>
      ),
    },
    {
      header: "互检结果",
      size: 240,
      accessorKey: "inspectResult",
      cell: ({ row }) => (
        <>
          <Form.Item noStyle name={[row.index, "id"]} initialValue={row.id} />
          <Form.Item name={[row.index, "inspectResult"]} rules={[{ required: true, message: "请选择" }]}>
            <Space>
              <CheckBtn
                checkValue={OPERATION_RESULT.OK}
                className={common.qualified}
                row={row}
                form={form}
                type="primary"
                activeBgColor={"#00DEEC"}
              >
                OK
              </CheckBtn>
              <CheckBtn
                checkValue={OPERATION_RESULT.NG}
                className={common.unqualified}
                row={row}
                form={form}
                activeBgColor={"rgb(255, 0, 0)"}
              >
                NG
              </CheckBtn>
            </Space>
          </Form.Item>
        </>
      ),
    },
    {
      header: "上传附件",
      size: 228,
      accessorKey: "faultFile",
      cell: ({ row }) => (
        <>
          <InputFormComponent
            name={[row.index, "faultFile"]}
            opType={STEP_OPERATE_TYPE.IMPORT.code}
            rules={[{ required: false }]}
            inputProps={{
              className: common.input,
              style: { width: 180, height: 50 },
              prefix: null,
            }}
          />
        </>
      ),
    },
    {
      header: "备注",
      size: 228,
      accessorKey: "remark",
      cell: ({ row }) => (
        <Form.Item name={[row.index, "remark"]}>
          <Input className={common.input} style={{ width: 180, height: 50 }} size="small" />
        </Form.Item>
      ),
    },
  ];

  // const dataS = [
  //   {
  //     description: "123",
  //     id: "1",
  //     item: "项目1",
  //     standardImage: "",
  //   },
  //   {
  //     description: "222",
  //     id: "2",
  //     item: "项目2",
  //     standardImage: "",
  //   },
  // ];

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "执行互检"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      width={1542}
      centered
    >
      {/* <Row style={{ margin: 16, padding: 10, background: `rgba(92, 156, 255, 0.1)` }}>
        <Col span={12} style={{ fontSize: 22 }}>
          互检名称：{`${searchParams.get("CODE") || "-"}`}
        </Col>
        <Col span={12} style={{ fontSize: 22 }}>
          岗位：{`${searchParams.get("stationName") || "-"}`}
        </Col>
      </Row> */}
      <Row className="row-btn">
        <Form form={form}>
          <Form.List name="items">
            {(fields) => (
              <Col span={24} className="container">
                <Flex style={{ height: 534, overflow: "hidden" }}>
                  <TableContent>
                    <TableComp columns={columns} dataSource={dataSource} />
                    {/* <TableComp columns={columns} dataSource={dataS} /> */}
                  </TableContent>
                </Flex>
              </Col>
            )}
          </Form.List>
        </Form>
        <Col
          offset={20}
          span={4}
          style={{
            textAlign: "right",
          }}
        >
          <Space>
            <Button
              type="primary"
              onClick={() => {
                handleCancel();
              }}
            >
              取消
            </Button>
            <Button
              type="primary"
              onClick={() => {
                handleOk();
              }}
            >
              互检完成
            </Button>
          </Space>
        </Col>
      </Row>
    </Modal>
  );
};

export default CrossCheckModal;
