import React, { useState } from "react";
import { Button, Form, Modal, Space, Col, message } from "antd";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import useRequest from "@ahooksjs/use-request";
import { unBindCar } from "@/services/toolBox";

//半成品下线
const EngineBindModal = () => {
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);

  let vin = searchParams.get("vin");
  let carNo = searchParams.get("carNo");
  let scheduleLogId = searchParams.get("scheduleLogId");

  const handleOk = () => {
    setIsModalOpen(false);
    closePopup();
    // 1. 通知Flutter关闭全屏容器
  };

  const { run: unBind, loading } = useRequest(unBindCar, {
    manual: true,
    onSuccess: (res) => {
      if (res.success) {
        message.success(res.message);
        handleOk();
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
  const onFinish = () => {
    unBind({
      carNo,
      vin,
      scheduleLogId,
    });
  };

  return (
    <Modal
      className="custom-modal"
      title={searchParams.get("title") || "半成品下线"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={() => {
        return (
          <Space>
            <Button
              type="primary"
              onClick={() => {
                handleCancel(); // 区分是否点击确认按钮
              }}
            >
              {"取消"}
            </Button>
            <Button
              type="primary"
              loading={loading}
              onClick={() => {
                onFinish(); // 区分是否点击确认按钮
              }}
            >
              {"确定"}
            </Button>
          </Space>
        );
      }}
    >
      <p>请问是否解除当前发动机与夹具号的绑定关系，解除绑定后，该发动机需要下线，无法进行后续装配。</p>
      <h5>机号：{vin}</h5>
      <h5>工装车标签：{scheduleLogId}</h5>
    </Modal>
  );
};

export default EngineBindModal;
