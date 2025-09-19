import React, { useEffect, useState } from "react";
import { Modal, Row, Col, Button, Flex, Space, message } from "antd";

import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import common from "../common.less";
import useRequest from "@ahooksjs/use-request";
import { changeThings } from "@/services/stepRequisition";
// 更换弹窗
const ReplaceModal = () => {
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();
  const paramsObject = Object.fromEntries(searchParams.entries());

  const [isModalOpen, setIsModalOpen] = useState(true);

  const [dataSource, setDataSource] = useState([]);

  useEffect(() => {
    const { serialNumberList, ...record } = paramsObject;
    if (serialNumberList) {
      setDataSource(serialNumberList?.split(",")?.map((n) => ({ serialNumber: n, ...record })));
    }
  }, []);

  const { run: changeRun } = useRequest(changeThings, {
    manual: true,
  });

  const handleOk = () => {
    if (dataSource.length) {
      changeRun({
        reqId: paramsObject.reqId,
        serialNumberList: dataSource.map(({ serialNumber }) => serialNumber),
      }).then((res) => {
        if (res.success) {
          setIsModalOpen(false);
          // 1. 通知Flutter关闭全屏容器
          closePopup(true);
        } else {
          message.error(res.message);
        }
      });
    }
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  const columns = [
    {
      header: "序号",
      size: 59,
      cell: ({ row }) => row.index + 1,
    },
    {
      header: "名称",
      size: 300,
      accessorKey: "thingsName",
    },
    {
      header: "编码",
      size: 100,
      accessorKey: "thingsCode",
    },
    {
      header: "批次号/序列号",
      size: 200,
      accessorKey: "serialNumber",
    },
    {
      header: "单位",
      size: 100,
      accessorKey: "unit",
    },
    {
      header: "操作",
      size: 100,
      accessorKey: "operation",
      cell: ({ row }) => (
        <Button
          type="link"
          danger
          style={{ color: "#ff7875" }}
          onClick={() => {
            const newDataSource = dataSource.filter((_, index) => index !== row.index);
            setDataSource(newDataSource);
          }}
        >
          移除
        </Button>
      ),
    },
  ];

  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={paramsObject.title || "更换"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={false}
      width={1542}
      centered
    >
      <Row className="row-btn">
        <Col span={24} className="container">
          <Flex style={{ height: 534, overflow: "hidden" }}>
            <TableContent>
              <TableComp columns={columns} dataSource={Array.isArray(dataSource) ? dataSource : []} />
            </TableContent>
          </Flex>
        </Col>
        <Col
          offset={20}
          span={4}
          style={{
            marginTop: 32,
            textAlign: "right",
          }}
        >
          <Space>
            <Button
              type="primary"
              onClick={() => {
                handleCancel();
              }}
            >
              取消
            </Button>
            {dataSource?.length > 0 && (
              <Button type="primary" onClick={handleOk}>
                提交
              </Button>
            )}
          </Space>
        </Col>
      </Row>
    </Modal>
  );
};

export default ReplaceModal;
