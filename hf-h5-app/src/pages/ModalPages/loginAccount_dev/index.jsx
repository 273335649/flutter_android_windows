import React, { useEffect, useState } from "react";
import { Button, Form, Modal, Row, Col, message, Image } from "antd";
import { useModel } from "@umijs/max";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
// import { loginApi } from "@/services/login";
import { getUserInfo, getUserFactoryOrg } from "@/services/demo";
import common from "../common.less";
//登录账号(登录弹窗和模拟岗位选择默认第一个产线第一个岗位)
const LoginAccountDev = ({ isOpen }) => {
  const { setInitialState } = useModel("@@initialState");
  const [modalForm] = Form.useForm();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(false);
  useEffect(() => {
    setIsModalOpen(isOpen);
  }, [isOpen]);
  const loginSubmit = () => {
    modalForm
      .validateFields()
      .then((val) => {
        const params = {
          ...val,
        };
        getUserInfo(params).then(async (res) => {
          if (res.success) {
            let otherToken = res.data?.loginToken?.access_token;
            localStorage.setItem("token", otherToken);
            let result = await getUserFactoryOrg();
            let loginInfo = res.data?.loginUser;
            loginInfo = {
              ...loginInfo,
              lineId: result.data?.[0]?.id,
              stationId: result.data?.[0]?.stationList[0]?.id,
              stationName: result.data?.[0]?.stationList[0]?.name,
            };
            localStorage.setItem("loginInfo", JSON.stringify(loginInfo));

            setInitialState((prev) => ({
              ...prev,
              userInfo: loginInfo,
              stationId: loginInfo?.stationId || null,
              lineId: loginInfo?.lineId || null,
            }));

            setIsModalOpen(false);
          } else {
            console.log("resMessage:", res.message);
            message.warning(res.message);
          }
        });
      })
      .catch((err) => {
        console.log("loginSubmit123123:", err);
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
      maskClosable={false}
      onCancel={() => {
        handleCancel();
      }}
      footer={false}
      closable={false}
    >
      <div className="modal-tips">请登陆账号,确认操作无误后,点击确定按钮</div>
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
            style={{ padding: 16 }}
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
            style={{ padding: 16 }}
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

export default LoginAccountDev;
