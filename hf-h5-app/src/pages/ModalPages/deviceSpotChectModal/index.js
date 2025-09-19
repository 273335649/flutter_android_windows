import React, { useEffect, useState } from "react";
import { Modal, Row, Col, Button, Flex, Image, Space, Form, message } from "antd";
import Input from "@/components/Input";
import InputFormComponent from "@/components/InputFormComponent";
import { useSearchParams, useModel, history } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import common from "../common.less";
import { materialSubmitApi, getCheckStdListApi, warrantySubmitApi } from "@/services/device";
import { STEP_OPERATE_TYPE } from "@/constants";
import LoadingFile from "@/components/LoadingFile";
const RepairSpotChectModal = () => {
  const [form] = Form.useForm();
  const [modalForm] = Form.useForm();
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null, stationId = null } = initialState;
  const { closePopup, openPopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);
  const [dataSource, setDataSource] = useState([]);
  const [isRepairModal, setIsRepairModal] = useState(false);

  // 获取检查标准列表
  const getCheckStdList = () => {
    getCheckStdListApi(searchParams.get("ID")).then((res) => {
      const { success, data } = res;
      if (success) {
        setDataSource(data);
      } else {
        message.warning(res.message);
      }
    });
  };

  useEffect(() => {
    getCheckStdList();
  }, []);

  const handleCancel = () => {
    setIsModalOpen(false);
    closePopup();
  };

  const columns = [
    {
      header: "编号",
      size: 59,
      accessorKey: "id",
      cell: ({ row }) => <div>{row.index + 1}</div>,
    },
    {
      header: "类型",
      size: 150,
      accessorKey: "opType",
      cell: (info) => STEP_OPERATE_TYPE[info.getValue()]?.name || "-",
    },
    {
      header: "工步名称",
      accessorKey: "stepName",
      size: 150,
    },
    {
      header: "工步内容",
      accessorKey: "content",
      size: 330,
    },
    {
      header: "工艺标准",
      accessorKey: "standard",
      size: 111,
      tooltip: true,
    },
    {
      header: "标准图片",
      accessorKey: "stepFile",
      size: 128,
      cell: ({ row }) => (
        <Flex justify={"center"} style={{ textIndent: 0 }}>
          <LoadingFile width={100} height={50} src={row.original?.stepFile} />
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
          <InputFormComponent
            name={[row.index, "resultValue"]}
            opType={row.original.opType}
            inputProps={{
              onChange: async (val) => {
                // 解析 inspectionStd 字符串，例如 "1~10" 格式
                const bool = await Inspection({ row, val });
                if (bool) {
                  form.setFieldValue(["items", row.index, "resultStatus"], bool);
                } else {
                  form.setFieldValue(["items", row.index, "resultStatus"], null);
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
          checkValue={"QUALIFIED"}
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
          checkValue={"UNQUALIFIED"}
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
  const CheckBtn = ({ row, form, activeBgColor, className, checkValue, children, ...resetProps }) => {
    const watchResultStatus = Form.useWatch(["items", row.index, "resultStatus"], form);
    return (
      <Button
        className={`${common.btn} ${className}`}
        style={watchResultStatus === checkValue ? { background: activeBgColor } : {}}
        onClick={async () => {
          const bool = await Inspection({ row });
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
  const Inspection = ({ row, val }) => {
    const { standardLower, standardUpper, opType } = row.original;
    return new Promise((resolve) => {
      if (opType === STEP_OPERATE_TYPE.TYPE_IN.code) {
        if (!val) {
          resolve(false);
        } else {
          if (standardLower && standardUpper) {
            // 检查输入值是否在范围内
            if (
              !isNaN(val) &&
              !isNaN(standardLower) &&
              !isNaN(standardUpper) &&
              val >= standardLower &&
              val <= standardUpper
            ) {
              resolve("QUALIFIED");
            } else {
              resolve("UNQUALIFIED");
            }
          } else {
            resolve(false);
          }
        }
      } else {
        resolve(false);
      }
    });
  };
  //点检提交
  const materialSubmit = async () => {
    try {
      const values = await form.validateFields();
      console.log("values: ", values);

      const hasUnjudgedItem = values.items.some((item) => !item.resultStatus);
      if (hasUnjudgedItem) {
        message.warning("请判断所有项目的合格性");
        return;
      }

      const params = {
        eqptId: searchParams.get("ID"),
        lineId: lineId,
        stationId: stationId,
        detailList: values.items.map((item, index) => ({
          id: dataSource[index]?.stdId,
          resultStatus: item.resultStatus,
          resultValue: item.resultValue,
          stepType: dataSource[index]?.opType,
          itemId: dataSource[index].id,
        })),
      };

      const res = await materialSubmitApi(params);

      if (res.success) {
        message.success(res.message, 0.3, () => {
          setIsModalOpen(false);
          closePopup();
        });
      } else {
        message.error(res.message);
      }
    } catch (error) {
      console.error("表单验证失败:", error);
      // 优化：区分不同类型的错误信息
      if (error.errorFields && error.errorFields.length > 0) {
        message.error("请填写完整信息");
      } else {
        message.error("提交失败，请重试");
      }
    }
  };
  //维修提交
  const repaireSubmit = () => {
    modalForm.validateFields().then(() => {
      const params = {
        lineId: lineId,
        reason: modalForm.getFieldValue("reason"),
        stationId: stationId,
        eqptId: searchParams.get("ID"),
      };
      warrantySubmitApi(params).then((res) => {
        const { success } = res;
        if (success) {
          message.success(res.message, 0.5, () => {
            setIsRepairModal(false);
          });
        } else {
          message.warning(res.message);
        }
      });
    });
  };

  return (
    <div>
      <Modal
        className={`${common.content} custom-modal`}
        title={searchParams.get("title") || "执行点检"}
        open={isModalOpen}
        onCancel={handleCancel}
        footer={false}
        width={1542}
        centered
      >
        <Row style={{ margin: 16, padding: 10, background: `rgba(92, 156, 255, 0.1)` }}>
          <Col span={12} style={{ fontSize: 22 }}>
            设备编码：{`${searchParams.get("CODE")}`}
          </Col>
          <Col span={12} style={{ fontSize: 22 }}>
            设备名称：{`${searchParams.get("NAME")}`}
          </Col>
        </Row>
        <Row>
          <Col span={24} className="container">
            <Flex style={{ height: 534, overflow: "auto" }}>
              <Form form={form}>
                <Form.List name="items">
                  {(fields) => (
                    <TableContent>
                      <TableComp columns={columns} dataSource={dataSource} />
                    </TableContent>
                  )}
                </Form.List>
              </Form>
            </Flex>
          </Col>
          <Col offset={18} style={{ textAlign: "right" }}>
            <Row className="row-btn">
              <Space>
                <Button type="primary" onClick={handleCancel}>
                  取消
                </Button>
                <Button
                  className="abnormal-btn"
                  type="primary"
                  onClick={() => {
                    setIsRepairModal(true);
                  }}
                >
                  异常报修
                </Button>
                <Button type="primary" onClick={materialSubmit}>
                  点检完成
                </Button>
              </Space>
            </Row>
          </Col>
        </Row>
      </Modal>

      <Modal
        className="custom-modal"
        title={"设备异常"}
        open={isRepairModal}
        onCancel={() => {
          setIsRepairModal(false);
          modalForm.resetFields();
        }}
        footer={false}
      >
        <div style={{ marginBottom: 20 }}>
          <div>是否对当前点检设备发起报修?</div>
        </div>
        <Form form={modalForm} layout="vertical" className="modal-form" onFinish={repaireSubmit}>
          <Form.Item name="reason" label="报修原因" rules={[{ required: true, message: "请输入报修原因" }]}>
            <Input
              className={`${common.inputborder} ${common.input} ${common.areainput}`}
              placeholder="请输入"
              style={{ height: 120 }}
            />
          </Form.Item>
          <Form.Item label="">
            <Row className="row-btn">
              <Col span={24} style={{ textAlign: "right" }}>
                <Button
                  type="primary"
                  style={{ margin: "0 8px" }}
                  onClick={() => {
                    setIsRepairModal(false);
                    modalForm.resetFields();
                  }}
                >
                  取消
                </Button>
                <Button type="primary" htmlType="submit">
                  确定
                </Button>
              </Col>
            </Row>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default RepairSpotChectModal;
