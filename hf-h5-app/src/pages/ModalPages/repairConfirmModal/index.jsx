import React, { useState, useEffect } from "react";
import { Button, Form, Modal, Row, Col, Upload, message } from "antd";
import Input from "@/components/Input";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import common from "../common.less";
import useRequest from "@ahooksjs/use-request";
import { getDictListApi, getListApi } from "@/services/common";
import Select from "@/components/Select";
import MyUpload from "@/components/MyUpload";

//返修确认
const RepairConfirmModal = () => {
  const [modalForm] = Form.useForm();
  const { closePopup } = usePopup();
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(true);
  const [params] = useState({
    current: 1,
    size: 9999,
    tableCode: "MES_FAULT_TYPE",
    valueMap: {},
    orderMap: {},
  });

  const { data: faultCategoryData } = useRequest(getDictListApi, {
    manual: false,
    defaultParams: ["RE_REPAIR_TYPE"],
    formatResult: (res) => res?.data || res,
  });

  const { data: faultData } = useRequest(getListApi, {
    manual: false,
    defaultParams: [params],
    formatResult: (res) => res?.data || res,
    onSuccess: (res) => {
      if (res.message) {
        message.info(res.message);
      }
    },
  });

  const handleOk = (data) => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(data);
  };

  const onFinish = (values) => {
    try {
      let data = {
        ...values,
        repairType: values.repairType?.[0],
        faultFile: JSON.stringify(values?.faultFile),
      };
      handleOk(data);
    } catch (error) {
      console.error(error, "解析错误");
    }
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "返修确认"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      maskClosable={false}
    >
      <Form form={modalForm} layout="vertical" className="modal-form" onFinish={onFinish}>
        <Form.Item label="返修类型" name="repairType" required>
          <Select
            placeholder="请选择"
            options={faultCategoryData?.map(({ code, label }) => ({ value: code, label }))}
          />
        </Form.Item>
        <Form.Item noStyle label="故障ID" name="faultId" required />
        <Form.Item label="故障代码" name="faultCode" required>
          <Select options={faultData?.records?.map(({ CODE }) => ({ value: CODE, label: CODE }))} />
        </Form.Item>
        <Form.Item noStyle shouldUpdate={(prevValues, curValues) => prevValues.faultCode !== curValues.faultCode}>
          {({ getFieldValue }) => {
            const faultCode = getFieldValue("faultCode");
            const selectedFault = faultData?.records?.find((item) => item.CODE === faultCode?.[0]);
            if (modalForm.getFieldValue("faultName") !== selectedFault?.NAME) {
              modalForm.setFieldsValue({
                faultName: selectedFault?.NAME,
                faultId: selectedFault?.ID,
              });
            }
            return (
              <Form.Item label="故障名称" name="faultName" required>
                <Input placeholder="请选择" disabled />
              </Form.Item>
            );
          }}
        </Form.Item>
        <Form.Item label="故障附件" extra={"最大支持100M支持格式jpg/png/mp4"} name="faultFile" colon={false}>
          <MyUpload
            fileNum={1}
            fileSize={100}
            fileType={["file-JPG", "file-JPEG", "file-PNG"]}
            getForm={() => {
              return modalForm.getFieldValue("faultFile");
            }}
          />
        </Form.Item>
        <Form.Item label="故障备注" name={"remark"} rules={[{ max: 30, message: "最多输入30个字符" }]}>
          <Input placeholder="请输入" />
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
                  handleCancel();
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

export default RepairConfirmModal;
