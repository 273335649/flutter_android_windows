import React, { useEffect, useState } from "react";
import LeftInfo from "@/components/LeftInfo";
import { Flex, Tooltip } from "antd";
import RightTop from "@/components/RightTop";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { getListApi } from "@/services/common";
import usePopup from "@/hooks/usePopup";
export default () => {
  const { openPopup } = usePopup();
  const [dataSource, setDataSource] = useState([]);
  const columns = [
    {
      header: "返修单号",
      accessorKey: "ID",
    },
    // {
    //   header: "机号",
    //   accessorKey: "machineNumber",
    // },
    {
      header: "生产订单",
      accessorKey: "ORDER_NO",
    },
    {
      header: "返修状态",
      accessorKey: "STATUS___L",
      cell: ({ row }) => {
        return <span style={{ color: `${row.original?.STATUS___C}` }}>{row.original.STATUS___L}</span>;
      },
    },
    {
      header: "发起岗位",
      accessorKey: "STATION_ID___L",
    },
    {
      header: "故障名称",
      accessorKey: "FAULT_ID___L",
    },
    // {
    //   header: "设备名称",
    //   accessorKey: "",
    // },
    {
      header: "故障附件",
      accessorKey: "FAULT_FILE",
      cell: ({ row }) => {
        const reqContent = row.original?.FAULT_FILE;
        return reqContent ? (
          <Tooltip title={Object.values(JSON.parse(reqContent))}>
            <div
              style={{ cursor: "pointer" }}
              onClick={() => {
                checkFile(reqContent);
                readFile(row.original);
              }}
            >
              {reqContent ? Object.values(JSON.parse(reqContent)) : ""}
            </div>
          </Tooltip>
        ) : (
          "-"
        );
      },
    },
    {
      header: "发起人",
      accessorKey: "CREATE_NAME",
    },
    {
      header: "发起时间",
      accessorKey: "CREATE_TIME",
    },
  ];
  const getList = () => {
    const params = {
      current: 1,
      size: 9999,
      tableCode: "MES_RE_REPAIR",
      valueMap: {},
      orderMap: { CREATE_TIME: "DESC" },
    };
    getListApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setDataSource(data?.records);
      } else {
        message.warning(res.message);
      }
    });
  };
  useEffect(() => {
    let hasToken = sessionStorage.getItem("repaireToken");
    console.log("hasToken: ", hasToken);
    if (hasToken) {
      getList();
    }
  }, []);

  return (
    <Flex>
      <LeftInfo isRepairForm={true} bottomBtnShow={true} getList={getList} />
      <div className="right-container">
        <RightTop title={"返修"} />
        <TableContent>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </div>
    </Flex>
  );
};
