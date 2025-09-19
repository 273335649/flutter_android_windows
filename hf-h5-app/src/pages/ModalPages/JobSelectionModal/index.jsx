import React, { useState } from "react";
import { Button, Form, Modal, Row, Col, Select, Upload } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import common from "../common.less";
import useRequest from "@ahooksjs/use-request";
import { getUserFactoryOrg } from "@/services/demo";

//岗位选择
const JobSelectionModal = () => {
  const [modalForm] = Form.useForm();
  const lineId = Form.useWatch("lineId", modalForm);
  const stationId = Form.useWatch("stationId", modalForm);
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);

  const { data: orgList } = useRequest(getUserFactoryOrg, {
    manual: false,
    formatResult: (res) => res.data,
  });
  console.log(orgList, "orgList123");
  // const [stationList, setStationList] = useState([]);
  let stationList = orgList?.find(({ id }) => id === lineId)?.stationList;
  let subStationList = stationList?.find(({ id }) => id === stationId)?.childStationList;
  const handleCancel = (otherToken) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    console.log(otherToken, "otherToken");
    closePopup(otherToken);
  };
  const onFinish = (values) => {
    let data = {
      ...values,
      stationName: stationList?.find(({ id }) => id === values.stationId)?.name,
    };
    if (values.subStationId) {
      data = {
        ...values,
        stationId: values.subStationId,
        stationName: subStationList?.find(({ id }) => id === values.subStationId)?.name,
      };
    }
    handleCancel(data);
  };

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "系统提示"}
      open={isModalOpen}
      onCancel={() => {
        handleCancel();
      }}
      footer={false}
    >
      <Form form={modalForm} onFinish={onFinish} layout="vertical" className="modal-form">
        <Form.Item label="请选择产线" name={"lineId"} rules={[{ required: true, message: "请选择" }]}>
          <Select placeholder="请选择" options={orgList?.map(({ id, name }) => ({ value: id, label: name }))} />
        </Form.Item>
        <Form.Item label="请选择岗位" name={"stationId"} rules={[{ required: true, message: "请选择" }]}>
          <Select placeholder="请选择" options={stationList?.map(({ id, name }) => ({ value: id, label: name }))} />
        </Form.Item>
        <Form.Item label="请选择子岗位" name={"subStationId"}>
          <Select placeholder="请选择" options={subStationList?.map(({ id, name }) => ({ value: id, label: name }))} />
        </Form.Item>
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
                取消
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

export default JobSelectionModal;
