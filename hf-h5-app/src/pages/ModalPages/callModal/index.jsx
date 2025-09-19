import React, { useState } from "react";
import { Modal, Button, Row, Col, Form, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams, useModel } from "umi";
import usePopup from "@/hooks/usePopup";
import { andonCallApi } from "@/services/andon";
import common from "../common.less";
const CallModal = () => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null, stationId = null, userInfo = {} } = initialState;
  const [modalForm] = Form.useForm();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);

  const andonCall = () => {
    modalForm.validateFields().then(() => {
      const params = {
        lineId: lineId,
        stationId: stationId,
        operatorId: userInfo?.userId,
        stationName: userInfo?.stationName,
        eventId: searchParams.get("eventId"),
        remark: modalForm.getFieldValue("remark"),
      };
      andonCallApi(params).then((res) => {
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
      title={searchParams.get("title")}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
    >
      <div style={{ marginBottom: 20 }}>
        <div>{`是否确定要发起${searchParams.get("eventName")}事件的呼叫？`}</div>
        <div style={{ fontSize: 18 }}>发起后需等待响应和事件处理</div>
      </div>
      <Form form={modalForm} layout="vertical" className="modal-form" onFinish={andonCall}>
        <Form.Item name="remark" label="备注" rules={[{ required: true, message: "请输入备注" }]}>
          <Input
            className={`${common.inputborder} ${common.input} ${common.areainput}`}
            style={{
              height: 120,
            }}
            placeholder="请输入"
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

export default CallModal;
