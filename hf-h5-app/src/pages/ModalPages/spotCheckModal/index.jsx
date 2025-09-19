import React, { useEffect, useState } from "react";
import { Modal, Row, Col, Button, Flex, Space, Form, Image, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import common from "../common.less";
import useRequest from "@ahooksjs/use-request";
import { getThingsCheckList, thingsCheck } from "@/services/stepRequisition";
import { STEP_OPERATE_TYPE, OPERATION_RESULT, THINGS_TYPE } from "@/constants";
import LoadingFile from "@/components/LoadingFile";
import InputFormComponent from "@/components/InputFormComponent";
import { useCommon } from "@/hooks/useCommon";
// 点检
const SpotCheckModal = () => {
  const [form] = Form.useForm();
  const { isInspection } = useCommon();
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();
  let reqId = searchParams.get("reqId");
  let thingsType = searchParams.get("thingsType");
  const [isModalOpen, setIsModalOpen] = useState(true);
  const watchItems = Form.useWatch("items", form);
  const {
    data,
    run: check,
    loading,
  } = useRequest(thingsCheck, {
    manual: true,
  });

  const {
    data: dataList,
    run: getData,
    loading: getLoading,
  } = useRequest(getThingsCheckList, {
    manual: true,
    formatResult: (res) => res?.data || res,
    onSuccess: (res) => {
      if (res?.success === false) {
      } else {
        form.setFieldValue("items", res);
      }
    },
  });

  useEffect(() => {
    if (reqId) {
      getData({ reqId });
    }
  }, [reqId]);

  const handleOk = () => {
    let values = form.getFieldsValue();
    let data = {
      reqId,
      ...values,
      items: values.items?.map(({ id, resultStatus, resultValue }) => ({
        id,
        resultStatus,
        resultValue: typeof resultValue === "string" ? resultValue : JSON.stringify(resultValue),
      })),
    };
    check(data).then((res) => {
      if (res.success) {
        message.success(res.message, 0.5, () => {
          setIsModalOpen(false);
          // 1. 通知Flutter关闭全屏容器
          closePopup(true);
        });
      } else {
        message.info(res.message);
      }
    });
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  let dataSource = dataList?.message ? [] : dataList;
  const columns = [
    {
      header: "编号",
      size: 59,
      accessorKey: "no",
    },
    {
      header: "类型",
      size: 93,
      accessorKey: "opType",
      cell: (info) => STEP_OPERATE_TYPE[info.getValue()]?.name || "-",
    },
    {
      header: "工步名称",
      size: 193,
      accessorKey: "name",
    },
    {
      header: "工步内容",
      accessorKey: "content",
      size: 330,
    },
    {
      header: "工艺标准",
      accessorKey: "inspectionStd",
      size: 111,
      tooltip: true,
    },
    {
      header: "标准图片",
      accessorKey: "fileUrl",
      size: 128,
      cell: ({ row }) => (
        <Flex justify={"center"} style={{ textIndent: 0 }}>
          <LoadingFile width={100} height={50} src={row.original.fileUrl} />
        </Flex>
      ),
    },
    {
      header: "录入",
      size: 228,
      accessorKey: "type",
      // type	类型,关联字典STEP_OPERATE_TYPE
      cell: ({ row }) => (
        <>
          <Form.Item noStyle name={[row.index, "id"]} />
          <Form.Item noStyle name={[row.index, "resultStatus"]} />
          <InputFormComponent
            name={[row.index, "resultValue"]}
            opType={row.original.opType}
            inputProps={{
              onChange: async (val) => {
                // 解析 inspectionStd 字符串，例如 "1~10" 格式
                const bool = await isInspection({ row, val });
                if (bool) {
                  form.setFieldValue(["items", row.index, "resultStatus"], bool);
                }
              },
              className: common.input,
              style: { width: 180, height: 50 },
              prefix: null,
            }}
          />
        </>
      ),
    },
    {
      header: "合格",
      size: 136,
      cell: ({ row }) => (
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
      ),
    },
    {
      header: "不合格",
      size: 136,
      cell: ({ row }) => (
        <CheckBtn
          checkValue={OPERATION_RESULT.NG}
          className={common.unqualified}
          row={row}
          form={form}
          activeBgColor={"rgb(255, 0, 0)"}
        >
          NG
        </CheckBtn>
      ),
    },
  ];

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "执行点检"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      width={1542}
      centered
    >
      <Form form={form}>
        <Row className="row-btn">
          <Col span={24} className="container">
            {/* <LoadingFile width={100} height={50} src={`{"20250827102013370007.jpg":"22131.jpg"}`} /> */}
            <Flex style={{ height: 534, overflow: "hidden" }}>
              <Form.List name="items">
                {(fields, { add, remove }) => (
                  <>
                    <TableContent>
                      <TableComp
                        emptyMessage={dataList?.message}
                        loading={getLoading}
                        columns={columns}
                        dataSource={dataSource}
                      />
                    </TableContent>
                  </>
                )}
              </Form.List>
            </Flex>
          </Col>
          <Col
            span={24}
            style={{
              marginBlock: 40,
              visibility: dataSource?.length ? "visible" : "hidden",
              ...(watchItems && watchItems.some((item) => item.resultStatus === OPERATION_RESULT.NG)
                ? {}
                : { display: "none" }),
            }}
            className="modal-form"
          >
            <Row gutter={16}>
              <Col span={12}>
                <Form.Item
                  label="不合格原因"
                  name={"ngReason"}
                  rules={[{ required: true, message: "请输入不合格原因" }]}
                  labelCol={{ span: 6 }}
                  wrapperCol={{ span: 16 }}
                >
                  <Input placeholder="请输入不合格原因" />
                </Form.Item>
              </Col>
              <Col
                span={12}
                style={
                  thingsType === THINGS_TYPE.MATERIAL || thingsType === THINGS_TYPE.TOOL ? { display: "none" } : {}
                }
              >
                <Form.Item
                  label="批次号/序列号"
                  name={"ngSerialNumberList"}
                  rules={[{ required: true, message: "请输入批次号/序列号" }]}
                  labelCol={{ span: 6 }}
                  wrapperCol={{ span: 16 }}
                >
                  <Input placeholder="请输入批次号/序列号" />
                  {/* <Select options={serialNumberList?.map((num) => ({ value: num, label: num }))} /> */}
                </Form.Item>
              </Col>
            </Row>
          </Col>
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
                  // handleCancel();
                  let values = form.getFieldsValue();
                  console.log(values, "values");
                }}
              >
                取消
              </Button>
              <Button
                hidden={!dataSource?.length}
                loading={loading}
                type="primary"
                onClick={() => {
                  handleOk();
                }}
              >
                提交
              </Button>
            </Space>
          </Col>
        </Row>
      </Form>
    </Modal>
  );
};

export default SpotCheckModal;

const CheckBtn = ({ row, form, activeBgColor, className, checkValue, children, ...resetProps }) => {
  const { isInspection } = useCommon();
  const watchResultStatus = Form.useWatch(["items", row.index, "resultStatus"], form);
  return (
    <Button
      className={`${common.btn} ${className}`}
      style={watchResultStatus === checkValue ? { background: activeBgColor } : {}}
      onClick={async () => {
        const bool = await isInspection({ row });
        if (bool) {
          form.setFieldValue(["items", row.index, "resultStatus"], bool);
        } else {
          form.setFieldValue(["items", row.index, "resultStatus"], checkValue);
        }
      }}
      {...resetProps}
    >
      {children}
    </Button>
  );
};
