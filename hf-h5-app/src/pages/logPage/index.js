import React, { useEffect, useState } from "react";
import LeftInfo from "@/components/LeftInfo";
import { Flex, Tooltip, message } from "antd";
import RightTop from "@/components/RightTop";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { logListApi } from "@/services/log";
export default () => {
  const [dataSource, setDataSource] = useState([]);
  const columns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "id",
      cell: ({ row }) => {
        return <div>{row.index + 1}</div>;
      },
    },
    {
      header: "时间",
      size: 255,
      accessorKey: "createTime",
    },
    {
      header: "操作",
      accessorKey: "operator",
      size: 150,
    },
    {
      header: "请求内容",
      accessorKey: "reqContent",
      size: 500,
      cell: ({ row }) => {
        const reqContent = row.original.reqContent;
        return reqContent ? (
          <Tooltip title={reqContent}>
            <div className="ellipsis-multiline">{reqContent}</div>
          </Tooltip>
        ) : (
          "-"
        );
      },
    },
    {
      header: "	响应内容",
      accessorKey: "respContent",
      size: 500,
      cell: ({ row }) => {
        const respContent = row.original.respContent;
        return respContent ? (
          <Tooltip title={respContent}>
            <div className="ellipsis-multiline">{respContent}</div>
          </Tooltip>
        ) : (
          "-"
        );
      },
    },
    {
      header: "path",
      accessorKey: "path",
      size: 255,
    },
  ];

  const getLogList = () => {
    const params = {
      current: 1,
      size: 9999,
    };
    logListApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setDataSource(data?.records);
      } else {
        message.warning(res.message);
      }
    });
  };
  useEffect(() => {
    getLogList();
  }, []);
  return (
    <Flex>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"日志清单"} />
        <TableContent>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </div>
    </Flex>
  );
};
