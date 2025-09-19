import React, { useState } from "react";
import { Button, Form, Modal, Row, Col, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import common from "@/pages/ModalPages/common.less";
import WorkOrderModal from "@/pages/ModalPages/workOrderModal";
import usePopup from "@/hooks/usePopup";
import useRequest from "@ahooksjs/use-request";
import { useDebounceFn } from "@/hooks/useDebounceFn";
import { bindCar } from "@/services/toolBox";
import { getVinInfo } from "@/services/productionOrder";
//发动机上线绑定弹窗
const EngineBindModal = () => {
  const { closePopup } = usePopup();
  const [modalForm] = Form.useForm();
  const formVin = Form.useWatch("vin", modalForm);
  const formCarNo = Form.useWatch("carNo", modalForm);
  const [searchParams] = useSearchParams();
  const [visible, setVisible] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(true);

  const { run: fetchEngineInfo } = useRequest(getVinInfo, {
    manual: true,
    formatResult: (res) => res?.data || res,
  });

  const debouncedFetchEngineInfo = useDebounceFn(async (vin, callback) => {
    callback?.(await fetchEngineInfo({ vin }));
  }, 500);

  const handleOk = () => {
    setIsModalOpen(false);
    closePopup();
    // 1. 通知Flutter关闭全屏容器
  };

  const { run: bind, loading } = useRequest(bindCar, {
    manual: true,
    onSuccess: (res) => {
      if (res.success) {
        message.success(res.message || "绑定成功", () => {
          handleOk();
        });
      } else {
        message.info(res.message);
      }
    },
  });

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  const onFinish = (values) => {
    bind({ ...values });
  };

  return (
    <Modal
      className="custom-modal"
      title={searchParams.get("title") || "发动机上线绑定"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      maskClosable={false}
    >
      <Form form={modalForm} layout="vertical" onFinish={onFinish} className="modal-form">
        <Form.Item
          label="机号"
          name={"vin"}
          rules={[
            { required: true, message: "请扫描或输入机号" },
            {
              validator: async (_, value) => {
                if (value) {
                  const res = await new Promise((resolve) => {
                    debouncedFetchEngineInfo(value, (result) => {
                      resolve(result);
                    });
                  });
                  if (res && res.message) {
                    return Promise.reject(new Error(res.message));
                  }
                }
                return Promise.resolve();
              },
            },
          ]}
        >
          <Input
            className={`${common["input-content-bg"]}`}
            suffix={<img src={require("@/assets/scan-icon.png")} />}
            placeholder="请扫描或输入"
          />
        </Form.Item>
        <Form.Item noStyle label="工单Id" name={"stationLogId"} hidden />
        <Form.Item label="工单" name={"stationLogName"} rules={[{ required: true, message: "请选择工单" }]}>
          <Input
            readOnly={true}
            onClick={() => {
              let vin = modalForm.getFieldValue("vin");
              if (vin) {
                setVisible(!visible);
              } else {
                modalForm.validateFields(["vin"]);
              }
            }}
            className={`${common["input-content-bg"]}`}
            suffix={<img src={require("@/assets/chevron-right.png")} />}
            placeholder="请选择"
          />
        </Form.Item>
        <Form.Item label="工装车标签" name={"carNo"} rules={[{ required: true, message: "请扫描或输入" }]}>
          <Input
            className={`${common["input-content-bg"]}`}
            suffix={<img src={require("@/assets/scan-icon.png")} />}
            placeholder="请扫描或输入"
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
                取消
              </Button>
              <Button loading={loading} type="primary" htmlType="submit">
                确定
              </Button>
            </Col>
          </Row>
        </Form.Item>
      </Form>
      <WorkOrderModal
        visible={visible}
        setVisible={setVisible}
        selectedFn={(item) => {
          modalForm.setFieldValue("stationLogName", item.name);
          modalForm.setFieldValue("stationLogId", item.id);
        }}
        record={{ vin: formVin, carNo: formCarNo }}
      />
    </Modal>
  );
};

export default EngineBindModal;
