import React, { useState, useRef, useEffect } from "react";
import { useModel } from "umi";
import { Flex, message, Divider, Tooltip, Form, Row, Col, Button, Image } from "antd";
import Input from "@/components/Input";
import LeftInfo from "@/components/LeftInfo";
import RightTop from "@/components/RightTop";
import "./index.less";
import common from "../ModalPages/common.less";
import { listAndonTypeApi } from "@/services/andon";
import usePopup from "@/hooks/usePopup";
import { EmptyComp } from "@/components/EmptyComp";
import { loginApi } from "@/services/login";
export default () => {
  const [modalForm] = Form.useForm();
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null } = initialState;
  const { openPopup, closePopup } = usePopup();
  const [navCurrent, setNavCurrent] = useState(0);
  const containerRef = useRef(null);
  const [abnormalList, setAbnormalList] = useState([]);
  const hasToken = sessionStorage.getItem("andonToken");
  const secondRealName = sessionStorage.getItem("secondRealName");
  const secondUserId = sessionStorage.getItem("secondUserId");
  const [hasInfo, setHasInfo] = useState(false);
  // 状态分类数据
  const statusList = [{ name: "完结状态" }, { name: "呼叫状态" }, { name: "超时状态" }, { name: "响应状态" }];

  // 处理导航点击
  const handleNavClick = (index, id) => {
    setNavCurrent(index);
    const element = document.getElementById(id);
    if (element && containerRef.current) {
      containerRef.current.scrollTo({
        top: element.offsetTop - containerRef.current.offsetTop,
        behavior: "smooth",
      });
    }
  }; //列表
  const getAbnormalList = () => {
    const params = {
      isCall: false,
      lineId: lineId,
    };
    listAndonTypeApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setAbnormalList(data);
      } else {
        message.warning(res.message);
      }
    });
  };

  //退出登录
  const logOut = () => {
    sessionStorage.removeItem("andonToken");
    sessionStorage.removeItem("secondRealName");
    sessionStorage.removeItem("secondUserId");
    setAbnormalList([]);
    setHasInfo(false);
  };
  //登录
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
          return Promise.reject(errorMsg); // 转换为rejected状态以便统一捕获
        }
        let loginInfo = res.data;
        sessionStorage.setItem("andonToken", loginInfo?.loginToken?.access_token);
        sessionStorage.setItem("secondRealName", loginInfo?.loginUser?.realName);
        sessionStorage.setItem("secondUserId", loginInfo?.loginUser?.userId);
        setHasInfo(true);
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
  useEffect(() => {
    if (hasToken && lineId) {
      getAbnormalList();
    } else {
      setHasInfo(false);
      setAbnormalList([]);
    }
  }, [hasToken]);

  return (
    <Flex gap={12}>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"安灯响应"} />
        {!hasInfo ? (
          <div className="login-show">
            <div className="login-content">
              <div className="login-tips">欢迎使用安灯响应功能</div>
              <Form form={modalForm} layout="vertical" className="login-form" onFinish={loginSubmit}>
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
                    prefix={<Image preview={false} src={require("@/assets/clear-icon.png")} />}
                  />
                </Form.Item>

                <Form.Item>
                  <Row className="login-btn">
                    <Col
                      span={24}
                      style={{
                        textAlign: "center",
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
            </div>
          </div>
        ) : (
          <div className="andon-response">
            {/* 导航列表 */}
            <div className="nav-list">
              {abnormalList?.map((item, index) => (
                <div
                  className={`nav-item ${index === navCurrent ? "nav-item-active" : ""}`}
                  key={item.id}
                  onClick={() => handleNavClick(index, item.id)}
                >
                  {item.name}
                </div>
              ))}
            </div>

            {/* 右侧内容区域 */}
            <div className="abnormal-right">
              <div className="status-show">
                <div className="status-list">
                  {statusList.map((item, index) => (
                    <span key={index}>{item.name}</span>
                  ))}
                </div>
                {secondRealName && (
                  <div className="oprate">
                    <span>操作人:{secondRealName}</span>
                    <Divider type="vertical" className="divider-show" />
                    <div className="exit" onClick={logOut}>
                      <img src={require("@/assets/exit-icon.png")} alt="" />
                      <span> 退出</span>
                    </div>
                  </div>
                )}
              </div>

              {/* 可滚动区域 */}
              <div className="abnormal-scroll" ref={containerRef}>
                {abnormalList?.length > 0 ? (
                  <>
                    {abnormalList?.map((category) => (
                      <div key={category.id} id={category.id} className="abnormal-box">
                        <div className="name">{category.name}</div>
                        <div className="abnormal-list">
                          {category.eventList.map((item, index) => (
                            <Tooltip title={item?.eventName} key={index}>
                              <div
                                onClick={() => {
                                  openPopup({
                                    url: "/modal/responseModal",
                                    modalProps: {
                                      title: `${
                                        item.status === 0 || item.status === 1
                                          ? "呼叫响应"
                                          : item.status === 2 || item.status === 4
                                          ? "呼叫完结"
                                          : ""
                                      }`,
                                      ...item,
                                      operatorId: secondUserId,
                                      onCancel: () => {
                                        getAbnormalList();
                                      },
                                    },
                                  });
                                }}
                                className={`abnormal-item ${
                                  // 0-呼叫 1-响应超时 2-响应 3-完结 4-完结超时
                                  item.status === 3
                                    ? " default-color"
                                    : item.status === 2
                                    ? "green-color"
                                    : item.status === 0
                                    ? "yellow-color"
                                    : "red-color"
                                }`}
                              >
                                <div className="event ellipsis-multiline">{item?.eventName} </div>
                                <span className="count-show">{item?.count}</span>
                              </div>
                            </Tooltip>
                          ))}
                        </div>
                      </div>
                    ))}
                  </>
                ) : (
                  <EmptyComp />
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </Flex>
  );
};
