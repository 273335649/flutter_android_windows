import React, { useState } from "react";
import { Button, Form, Modal, Row, Col, message, Image } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import { loginApi } from "@/services/login";
import common from "../common.less";
//登录账号
const LoginAccount = () => {
  const [modalForm] = Form.useForm();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);
  const loginSubmit = () => {
    let params;
    modalForm
      .validateFields()
      .then((val) => {
        params = { ...val };
        return loginApi(params);
      })
      .then((res) => {
        if (!res?.success) {
          const errorMsg = res?.message || "登录失败";
          console.error("登录失败:", { response: res });
          // message.warning(errorMsg);
          return Promise.reject(errorMsg); // 转换为rejected状态以便统一捕获
        }
        handleCancel(res.data);
      })
      .catch((err) => {
        // 这里会捕获验证错误和API调用错误
        const errorMsg = err?.message || err || "登录过程中发生错误";
        console.error("登录提交错误:", { error: err });

        // 避免重复显示警告（如果前面已经显示过）
        if (errorMsg !== "登录失败") {
          message.warning(typeof err === "string" ? err : errorMsg);
        }
      });
  };
  const handleCancel = (otherToken) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(otherToken);
  };
  return (
    <Modal
      width={470}
      className="custom-modal"
      title={searchParams.get("title") || "系统提示"}
      open={isModalOpen}
      // onOk={handleOk}
      onCancel={() => {
        handleCancel();
      }}
      footer={false}
      closable={false}
      maskClosable={false}
    >
      <div className="modal-tips">请登录账号，确认操作无误后，点击确定按钮</div>
      <Form form={modalForm} layout="vertical" className="modal-form" onFinish={loginSubmit}>
        <Form.Item
          name="username"
          rules={[
            {
              required: true,
              message: "请输入账号",
            },
          ]}
        >
          <Input
            placeholder="请输入账号"
            className={common.loginiput}
            allowClear={{
              clearIcon: <Image preview={false} src={require("@/assets/chevron-right.png")} />,
            }}
            prefix={<Image preview={false} src={require("@/assets/account-icon.png")} />}
          />
        </Form.Item>
        <Form.Item
          name="password"
          rules={[
            {
              required: true,
              message: "请输入登录密码",
            },
          ]}
        >
          <Input
            placeholder="请输入密码"
            type="password"
            className={common.loginiput}
            allowClear={{
              clearIcon: <Image preview={false} src={require("@/assets/chevron-right.png")} />,
            }}
            prefix={<Image preview={false} src={require("@/assets/password-icon.png")} />}
          />
        </Form.Item>
        {/* <Form.Item
          name="password"
          rules={[
            {
              required: true,
              message: "扫码登录",
            },
          ]}
        >
          <Input prefix={<img src={require("@/assets/scan-icon.png")} />} placeholder="扫码登录" />
        </Form.Item> */}
        <Form.Item>
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

export default LoginAccount;
