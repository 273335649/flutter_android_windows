import React, { useEffect, useState } from "react";
import { useModel } from "umi";
import LeftInfo from "@/components/LeftInfo";
import { Badge, Button, Flex, message, Space } from "antd";
import RightTop from "@/components/RightTop";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import styles from "./index.less";
import { getListApi } from "@/services/common";
import usePopup from "@/hooks/usePopup";
export default () => {
  const { openPopup } = usePopup();
  const { initialState = {} } = useModel("@@initialState");
  const { stationId = null } = initialState;
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
      header: "设备编码",
      size: 255,
      accessorKey: "CODE",
    },
    {
      header: "设备名称",
      accessorKey: "NAME",
      size: 255,
    },
    {
      header: "设备类型",
      accessorKey: "EQPT_CLASS_NAME___L",
      size: 139,
    },
    {
      header: "维修状态",
      accessorKey: "REPAIR_STATUS___L",
      size: 144,
      cell: ({ row }) => {
        return <span style={{ color: `${row.original.REPAIR_STATUS___C}` }}>{row.original.REPAIR_STATUS___L}</span>;
      },
    },
    {
      header: "下发程序",
      accessorKey: "address4",
      size: 184,
      cell: () => <Button className={styles["action-button"]}>下发程序</Button>,
    },
    {
      header: "报修",
      accessorKey: "address5",
      size: 140,
      cell: ({ row }) => (
        <Button
          className={styles["action-button"]}
          onClick={() => {
            let itemInfo = row.original;
            if (itemInfo?.REPAIR_STATUS === "IN_REPAIR") {
              message.warning("当前设备正在维修中，请勿重复报修！");
            } else {
              openPopup({
                url: "/modal/deviceRepairModal",
                modalProps: {
                  title: "设备异常",
                  eqptId: itemInfo?.ID,
                  onCancel: () => {
                    getDeviceList();
                  },
                },
              });
            }
          }}
        >
          报修
        </Button>
      ),
    },
    {
      header: "点检",
      accessorKey: "address6",
      size: 140,
      cell: ({ row }) => (
        <Button
          className={styles["action-button"]}
          onClick={() => {
            let itemInfo = row.original;
            console.log("itemInfo: ", itemInfo);
            openPopup({
              url: "/modal/deviceSpotChectModal",
              modalProps: {
                title: "执行点检",
                ...itemInfo,
                onCancel: () => {
                  getDeviceList();
                },
              },
            });
          }}
        >
          点检
        </Button>
      ),
    },
  ];

  const getDeviceList = () => {
    const params = {
      current: 1,
      size: 9999,
      tableCode: "EAM_EQUIPMENT",
      valueMap: { STATION_ID: stationId },
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
    getDeviceList();
  }, []);
  return (
    <Flex>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"设备"} />
        <TableContent>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </div>
    </Flex>
  );
};
