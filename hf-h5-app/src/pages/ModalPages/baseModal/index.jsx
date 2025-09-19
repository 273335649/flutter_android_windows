import React, { useState } from "react";
import { Flex, Modal, Button } from "antd";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
// 基本弹窗
const BaseModal = () => {
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();

  const [isModalOpen, setIsModalOpen] = useState(true);

  const handleOk = (onOkArg) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(onOkArg);
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };
  const footer = JSON.parse(searchParams.get("footer"));

  return (
    <Modal
      width={392}
      className="custom-modal"
      title={searchParams.get("title") || "系统提示"}
      open={isModalOpen}
      onOk={handleOk}
      onCancel={handleCancel}
      footer={
        footer ? (
          <Flex>
            {footer.okText && (
              <Button
                key="submit"
                type="primary"
                onClick={() => {
                  console.log(2555);
                  handleOk(searchParams.get("onOkArg")); // 区分是否点击确认按钮
                }}
              >
                {footer.okText}
              </Button>
            )}
          </Flex>
        ) : (
          false
        )
      }
    >
      <div className="modal-content">{searchParams.get("content")}</div>
    </Modal>
  );
};

export default BaseModal;
