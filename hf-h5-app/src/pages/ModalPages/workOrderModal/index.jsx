import React, { useEffect, useState } from "react";
import { Flex, Modal, Button } from "antd";
import { useSearchParams } from "umi";
import TableComp from "@/components/TableComp";
import useRequest from "@ahooksjs/use-request";
import { getNotFinishSchedule } from "@/services/toolBox";
import TableContent from "@/components/TableContent";
import dayjs from "dayjs";

export const WorkOrderModal = ({ visible, setVisible, record, selectedFn }) => {
  const [searchParams] = useSearchParams();
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleOk = () => {
    setIsModalOpen(false);
    setVisible?.(false);
  };

  const handleCancel = () => {
    setIsModalOpen(false);
    setVisible?.(false);
  };

  const handleItemClick = (info) => {
    console.log("行被点击了:", info);
    selectedFn(info);
    handleOk();
    // 在这里添加你的点击回调逻辑
    // 例如，可以根据 info 中的数据执行一些操作
  };

  // 假设表格数据和列定义从 searchParams 获取，或者通过其他方式传入
  const {
    data: tableData = [],
    run: getList,
    loading,
  } = useRequest(getNotFinishSchedule, {
    manual: true,
    formatResult: (res) => res.data,
  });

  const tableColumns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "index",
      cell: ({ row }) => row.index + 1,
    },
    {
      header: "岗位计划号",
      size: 150,
      accessorKey: "scheduleNo",
    },
    {
      header: "生产订单号",
      size: 150,
      accessorKey: "orderNo",
    },
    // {
    //   header: "SAP订单号",
    //   size: 150,
    //   accessorKey: "scOrderNo",
    // },
    {
      header: "机型",
      size: 150,
      accessorKey: "jx",
    },
    {
      header: "状态码",
      size: 150,
      accessorKey: "materialCode",
    },
    {
      header: "计划时间",
      size: 200,
      accessorKey: "plannedTime",
      cell: (info) => <div>{`${dayjs(info.row.original.startDay)?.format("YYYY-MM-DD") || ""}`}</div>,
    },
    {
      header: "排产数量",
      size: 120,
      accessorKey: "qty",
    },
  ];
  useEffect(() => {
    if (visible) {
      getList({
        ...record,
      });
    }
    setIsModalOpen(visible);
  }, [visible, record]);

  return (
    <Modal
      width={searchParams.get("width") || 1200}
      className="custom-modal"
      title={searchParams.get("title") || "选择工单"}
      open={isModalOpen}
      onOk={handleOk}
      onCancel={handleCancel}
      footer={false}
      destroyOnHidden={true}
      destroyOnClose={true}
    >
      <div className="modal-content">
        {/* <Flex style={{ overflow: "hidden" }}> */}
        <TableContent>
          <TableComp
            indexKey={"id"}
            dataSource={tableData}
            columns={tableColumns}
            isItemClick={(info) => handleItemClick(info)}
            // 其他 TableComp props 可以根据需要添加
          />
        </TableContent>
        {/* </Flex> */}
      </div>
    </Modal>
  );
};

export default WorkOrderModal;
