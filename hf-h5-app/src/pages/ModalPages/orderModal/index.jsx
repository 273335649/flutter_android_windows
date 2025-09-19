import React, { useState } from "react";
import { Button, Modal } from "antd";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
// 请选择返修或让步接收
const OrderModal = () => {
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);
  const handleOk = (params) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(params);
  };

  const handleCancel = (params) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(params);
  };
  return (
    <Modal
      className="custom-modal"
      title={searchParams.get("title") || "系统提示"}
      open={isModalOpen}
      onOk={() => {
        handleOk();
      }}
      onCancel={() => {
        handleCancel();
      }}
      footer={[
        <Button
          key="back"
          onClick={() => {
            handleCancel({ type: "rework" });
          }}
        >
          返修
        </Button>,
        <Button
          key="submit"
          onClick={() => {
            handleOk({ type: "conces" });
          }}
        >
          让步接收
        </Button>,
      ]}
    >
      <div className="modal-content">请选择返修或让步接收</div>
    </Modal>
  );
};

export default OrderModal;
