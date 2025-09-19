import React, { useState } from "react";
import { Modal, Button, Row, Col, Form, message } from "antd";
import Input from "@/components/Input";
import common from "../common.less";
import { useSearchParams, useModel } from "umi";
import usePopup from "@/hooks/usePopup";
import { warrantySubmitApi } from "@/services/device";
const DeviceRepairModal = () => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null, stationId = null } = initialState;
  const [modalForm] = Form.useForm();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);

  const repaireSubmit = () => {
    modalForm.validateFields().then(() => {
      const params = {
        lineId: lineId,
        reason: modalForm.getFieldValue("reason"),
        stationId: stationId,
        eqptId: searchParams?.get("eqptId"),
      };
      warrantySubmitApi(params).then((res) => {
        const { success } = res;
        if (success) {
          message.success(res.message, 0.5, () => {
            handleCancel();
          });
        } else {
          message.warning(res.message);
        }
      });
    });
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  return (
    <Modal
      className="custom-modal"
      title={searchParams.get("title") || "设备异常"}
      open={isModalOpen}
      onCancel={handleCancel}
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
            <Col
              span={24}
              style={{
                textAlign: "right",
              }}
            >
              <Button
                type="primary"
                style={{
                  margin: "0 8px",
                }}
                onClick={() => {
                  modalForm.resetFields();
                }}
              >
                清空
              </Button>
              <Button type="primary" htmlType="submit">
                确定
              </Button>
            </Col>
          </Row>
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default DeviceRepairModal;
