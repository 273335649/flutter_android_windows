import React, { useState } from "react";
import { Modal, Row, Col, Button, Flex, Image, Space, Tabs } from "antd";
import { CameraOutlined, UploadOutlined } from "@ant-design/icons";

import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import common from "../common.less";
// 上传图片
const UploadImageModal = () => {
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();

  const [isModalOpen, setIsModalOpen] = useState(true);
  const handleOk = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };
  const columns = [
    {
      header: "编号",
      size: 59,
      accessorKey: "id",
    },
    {
      header: "名称",
      size: 300,
      accessorKey: "name",
    },
    {
      header: "标准图片",
      accessorKey: "standardImage",
      size: 128,
      cell: ({ row }) => (
        <Flex justify={"center"} style={{ textIndent: 0 }}>
          <Image width={100} height={50} src={row.original.standardImage || "https://via.placeholder.com/120x80"} />
        </Flex>
      ),
    },
    {
      header: "大小",
      size: 100,
      accessorKey: "size",
    },
    {
      header: "上传时间",
      size: 200,
      accessorKey: "uploadTime",
    },
    {
      header: "上传人",
      size: 100,
      accessorKey: "uploader",
    },
    {
      header: "操作",
      size: 100,
      accessorKey: "operation",
      cell: () => (
        <Button type="link" danger>
          删除
        </Button>
      ),
    },
  ];

  const dataSource = Array.from({ length: 6 }).map((_, i) => ({
    key: i,
    id: `${i + 1}`,
    name: `C801 I 25C039_OP030-3-013_2025年04月01日_16时31分29秒.jpg`,
    standardImage: `https://picsum.photos/id/${i + 10}/120/80`,
    size: "200kb",
    uploadTime: "2025-12-05 16:00:05",
    uploader: "张工",
  }));
  return (
    <Modal
      className={`${common.content} custom-modal`}
      title={searchParams.get("title") || "上传图片"}
      open={isModalOpen}
      onOk={handleOk}
      onCancel={handleCancel}
      footer={false}
      width={1542}
      centered
    >
      <Row className="row-btn">
        <Col span={24}>
          <Tabs defaultActiveKey="normal">
            <Tabs.TabPane tab="正常图: 5" key="normal">
              {/* 正常图内容 */}
            </Tabs.TabPane>
            <Tabs.TabPane tab="异常图: 0" key="abnormal">
              {/* 异常图内容 */}
            </Tabs.TabPane>
          </Tabs>
        </Col>
        <Col span={24} className={common["upload-btn"]}>
          <Space size={"large"}>
            <Button icon={<CameraOutlined style={{ color: "#18FEFE" }} />}>拍照</Button>
            <Button icon={<UploadOutlined style={{ color: "#18FEFE" }} />}>上传</Button>
            <span style={{ color: "#AAB3C1" }}>最大支持100M支持格式jpg/png/mp4,最多上传20张</span>
          </Space>
        </Col>
        <Col span={24} className="container">
          <Flex style={{ height: 534, overflow: "hidden" }}>
            <TableContent>
              <TableComp columns={columns} dataSource={dataSource} />
            </TableContent>
          </Flex>
        </Col>
      </Row>
    </Modal>
  );
};

export default UploadImageModal;
