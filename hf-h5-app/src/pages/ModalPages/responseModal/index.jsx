import React, { useState, useRef } from "react";
import { Modal, Button, Row, Col, Form, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import common from "../common.less";
import { andonResponseApi, andonFinishApi } from "@/services/andon";
const ResponseModal = () => {
  const inputRef = useRef();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);
  const status = searchParams?.get("status");
  const [remarkVal, setRemarkVal] = useState(null);
  // 状态映射对象
  const statusMap = {
    0: "呼叫",
    1: "响应超时",
    2: "响应",
    3: "完结",
    4: "完结超时",
  };
  const callInfo = [
    {
      name: "产线",
      value: searchParams.get("orgName"),
    },
    {
      name: "发起岗位",
      value: searchParams.get("stationName"),
    },
    {
      name: "呼叫人",
      value: searchParams.get("currentCallPersonName"),
    },
    {
      name: "呼叫时间",
      value: searchParams.get("currentCallTime"),
    },
    {
      name: "发起原因",
      value: searchParams.get("eventName"),
    },
    {
      name: "状态",
      value: statusMap[searchParams.get("status")] || `未知状态(${searchParams.get("status")})`,
    },
  ];

  const andonSubmit = async () => {
    try {
      const recordId = searchParams?.get("recordId");
      const operatorId = searchParams?.get("operatorId");
      const params = {
        recordId: recordId === "null" ? null : recordId,
        operatorId: operatorId === "null" ? null : operatorId,
        remark: remarkVal || null,
      };
      const apiCall = status === "1" ? andonResponseApi : andonFinishApi;
      const res = await apiCall(params);
      if (res?.success) {
        message.success(res.message, 0.5, () => {
          handleCancel();
        });
      } else {
        message.warning(res.message || "操作失败");
      }
    } catch (error) {
      console.error("提交失败:", error);
      message.error("请求处理失败，请稍后重试");
    }
  };
  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  return (
    <Modal
      className="custom-modal"
      title={searchParams.get("title") || "呼叫"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      width={864}
    >
      <div className="call-modal">
        {callInfo?.map((item, index) => (
          <div className="call-item" key={index}>
            <span className="name">{item.name}</span>
            <span className="value">{item.value}</span>
          </div>
        ))}
        <div className="call-item">
          <span className="name">处理备注</span>
          <span className="value">
            <Input
              style={{ height: 48 }}
              className={`${common.inputborder} ${common.input}`}
              placeholder="请输入"
              maxLength={30}
              ref={inputRef}
              onChange={(val) => {
                setRemarkVal(val);
              }}
            />
          </span>
        </div>
      </div>
      <Row className="row-btn">
        <Col
          span={24}
          style={{
            textAlign: "right",
          }}
        >
          <Button
            type="primary"
            onClick={() => {
              andonSubmit();
            }}
          >
            {status === "0" || status === "1" ? "响应" : status === "2" || status === "4" ? "完结" : ""}
          </Button>
        </Col>
      </Row>
    </Modal>
  );
};

export default ResponseModal;
