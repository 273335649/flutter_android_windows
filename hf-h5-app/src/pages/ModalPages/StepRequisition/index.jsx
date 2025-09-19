import React, { useState } from "react";
import { Modal, Row, Col, Button, Flex, Space, Form, message } from "antd";
import Input from "@/components/Input";
import InputNumber from "@/components/InputNumber";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import useRequest from "@ahooksjs/use-request";
import { getThingsToRequestList, reqThings } from "@/services/stepRequisition";
import { getDictListApi } from "@/services/common";
import common from "../common.less";
import { THINGS_TYPE } from "@/constants";
import Select from "@/components/Select";
import LoadingFile from "@/components/LoadingFile";

// 工步-领用-物品类型，物料工装工具等，关联字典THINGS_TYPE
const StepRequisitionModal = () => {
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();
  const [form] = Form.useForm();

  const [isModalOpen, setIsModalOpen] = useState(true);

  const { data: list } = useRequest(getDictListApi, {
    manual: false,
    defaultParams: ["THINGS_REQ_REASON_TYPE"],
    formatResult: (res) => res.data,
  });

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup({ type: "refresh" });
  };

  const { data: dataSource, mutate } = useRequest(getThingsToRequestList, {
    manual: false,
    defaultParams: [
      {
        vin: searchParams.get("vin"),
        thingsType: searchParams.get("thingsType"),
      },
    ],
    formatResult: (res) => res.data,
    onSuccess: (res) => {
      form.setFieldsValue({
        items: res.map((item) => ({
          ...item,
          requisitionQuantity: item.stdQty, // 默认填充领用数量为待领用数量
        })),
      });
    },
  });

  const { run: reqThingsRun } = useRequest(reqThings, {
    manual: true,
  });

  const handleOk = async () => {
    const values = await form.validateFields();
    let items = values.items;
    let data = {
      vin: searchParams.get("vin"),
      reqContentList: items?.map((v) => ({
        reqQty: v.requisitionQuantity,
        ...v,
        reqReason: v.reqReason?.[0],
      })),
    };
    // return;
    const res = await reqThingsRun(data);
    if (res.success) {
      message.success(res.message);
      setIsModalOpen(false);
      // 1. 通知Flutter关闭全屏容器
      closePopup({ type: "refresh" });
    } else {
      message.error(res.message);
    }
  };

  const columns = [
    {
      header: "序号",
      size: 59,
      cell: ({ row }) => row.index + 1,
      // accessorKey: "id",
      // cell: ({ row, getValue }) => (
      //   <Form.Item noStyle name={[row.index, "id"]}>
      //     {getValue()}
      //   </Form.Item>
      // ),
    },
    {
      header: "名称",
      size: 150,
      accessorKey: "thingsName",
    },
    {
      header: "编码",
      size: 120,
      accessorKey: "thingsCode",
    },
    {
      header: "单位",
      size: 80,
      accessorKey: "unit",
    },
    {
      header: "待领用数量",
      size: 120,
      accessorKey: "stdQty",
    },
    {
      header: "领用数量",
      size: 100,
      accessorKey: "requisitionQuantity",
      cell: ({ row }) => (
        <Form.Item noStyle name={[row.index, "requisitionQuantity"]}>
          <InputNumber
            style={{ width: "90%", height: "100%" }}
            min={0}
            max={99999}
            precision={0}
            onChange={(val) => {
              // 处理 InputNumber 的值变化
              console.log("InputNumber value changed:", val);
            }}
          />
        </Form.Item>
      ),
    },
  ];
  if (searchParams.get("thingsType") === THINGS_TYPE.MATERIAL) {
    columns.push({
      header: "领用原因",
      size: 150,
      accessorKey: "reqReason",
      cell: ({ row, getValue }) => (
        <Form.Item noStyle name={[row.index, "reqReason"]}>
          <Select
            options={list.map(({ code, label }) => ({ label, value: code }))}
            style={{ width: "90%", height: "100%" }}
            defaultValue={getValue()}
          />
        </Form.Item>
      ),
    });
  }
  columns.push({
    header: "备注",
    size: 150,
    accessorKey: "remark",
    cell: ({ row, getValue }) => (
      <Form.Item noStyle name={[row.index, "remark"]}>
        <Input style={{ width: "80%" }} defaultValue={getValue()} />
      </Form.Item>
    ),
  });

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "领用"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      width={1542}
      centered
    >
      <Row className="row-btn">
        {/* <LoadingFile width={100} height={50} src={`{"20250827102013370007.jpg":"22131.jpg"}`} /> */}
        <Col span={24} className="container">
          <Flex style={{ height: 534, overflow: "hidden" }}>
            <Form form={form} initialValues={{ items: [] }}>
              <Form.List noStyle name="items">
                {(fields, { remove }) => {
                  // 自定义移除方法，使用mutate更新dataSource
                  const handleRemove = (index) => {
                    // 1. 先执行Form.List提供的remove方法移除UI元素
                    remove(index);
                    // 2. 获取当前表单中的所有items数据
                    const currentItems = form.getFieldValue("items") || [];
                    console.log(currentItems, "currentItems123");
                    // 3. 创建新的数据列表，排除被删除的项
                    // const newItems = currentItems.filter((_, i) => i !== index);
                    // 5. 使用mutate同步更新dataSource，避免直接修改原始数据
                    // console.log(newItems, "newItems");
                    mutate([...currentItems]);
                  };

                  return (
                    <TableContent>
                      <TableComp
                        columns={[
                          ...columns,
                          {
                            header: "操作",
                            size: 100,
                            accessorKey: "operation",
                            cell: ({ row }) => (
                              <Button
                                type="link"
                                danger
                                onClick={() => {
                                  handleRemove(row.index);
                                }}
                              >
                                移除
                              </Button>
                            ),
                          },
                        ]}
                        dataSource={dataSource}
                      />
                    </TableContent>
                  );
                }}
              </Form.List>
            </Form>
          </Flex>
        </Col>
        <Col
          offset={20}
          span={4}
          style={{
            textAlign: "right",
          }}
        >
          <Space>
            <Button type="primary" onClick={handleCancel}>
              取消
            </Button>
            <Button hidden={!dataSource?.length} type="primary" onClick={handleOk}>
              提交
            </Button>
          </Space>
        </Col>
      </Row>
    </Modal>
  );
};

export default StepRequisitionModal;
