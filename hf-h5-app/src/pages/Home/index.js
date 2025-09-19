import React from "react";
import LeftInfo from "@/components/LeftInfo";
import { Button, Tabs, Flex } from "antd";
import TableComp from "@/components/TableComp";
import usePopup from "@/hooks/usePopup";
import TableContent from "@/components/TableContent";

export default () => {
  const { openPopup } = usePopup();
  const columns = [
    {
      header: "Full Name",
      size: 150,
      accessorKey: "name",
    },
    {
      header: "Age",
      size: 100,
      accessorKey: "age",
    },
    {
      header: "Column 1",
      accessorKey: "address",
      size: 200,
    },
    {
      header: "Column 2",
      accessorKey: "address1",
      size: 150,
    },
    {
      header: "Column 3",
      accessorKey: "address2",
      size: 150,
    },
    {
      id: "action",
      header: "Action",
      fixed: "right",
      size: 800,
      cell: () => {
        return (
          <Flex wrap>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "http://localhost:8000/modal/orderModal",
                  // url: "http://localhost:8000/modal/repairConfirmModal",
                  modalProps: {
                    onCancel: (params) => {
                      const { type } = params;
                      setTimeout(() => {
                        // 返修
                        if (type === "rework") {
                          openPopup({
                            url: "/modal/repairConfirmModal",
                            modalProps: {
                              onCancel: () => {
                                console.log("返修确认");
                              },
                            },
                          });
                        }
                        // 让步接收
                        if (type === "conces") {
                          openPopup({
                            url: "/modal/loginAccount",
                            modalProps: {
                              onCancel: () => {
                                console.log("让步接收");
                              },
                            },
                          });
                        }
                      }, 0);
                    },
                  },
                });
              }}
            >
              合格
            </Button>
            <Button
              type={"danger"}
              onClick={() => {
                openPopup({
                  modalProps: {
                    title: "系统提示",
                    content: "请等待巡检确认！",
                  },
                });
              }}
            >
              不合格
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "http://localhost:8000/modal/engineBindModal",
                  // url: "http://localhost:8000/modal/repairConfirmModal",
                });
              }}
            >
              发动机上线绑定
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "/modal/crossCheckModal",
                });
              }}
            >
              执行互检
            </Button>
            <Button
              onClick={() => {
                openPopup({
                  url: "/modal/containerNumModal",
                  modalProps: {
                    vin: "CA250822-0001",
                    lineId: "1798174175539040258",
                    stationId: "1009843243929575424",
                    visible: true,
                  },
                });
              }}
            >
              箱号
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  // url: "http://localhost:8000/modal/orderModal",
                  url: "http://localhost:8000/modal/repairConfirmModal",
                });
              }}
            >
              返修确认
            </Button>{" "}
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  // url: "http://localhost:8000/modal/orderModal",
                  url: "http://localhost:8000/modal/loginAccount",
                });
              }}
            >
              让步接收
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  // url: "http://localhost:8000/modal/orderModal",
                  url: "http://localhost:8000/modal/callModal",
                });
              }}
            >
              呼叫
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "/modal/spotCheck",
                });
              }}
            >
              点检
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "/modal/stepRequisition",
                  modalProps: {
                    thingsType: "FIXTURE",
                    vin: "CA5001-ⅡI24G002",
                    onCancel: (res) => {
                      console.log(res.type, "2225881");
                    },
                  },
                });
              }}
            >
              工步-领用
            </Button>
            <Button
              type={"primary"}
              onClick={() => {
                openPopup({
                  url: "/modal/uploadImage",
                });
              }}
            >
              上传图片
            </Button>
            <Button
              className="base-btn"
              onClick={() =>
                openPopup({
                  url: "/modal/testData",
                  modalProps: {
                    onCancel: (res) => {
                      console.log(res, "2225881");
                    },
                  }
                })
              }
            >
              测试数据
            </Button>
          </Flex>
        );
      },
    },
  ];

  const dataSource = Array.from({ length: 100 }).map((_, i) => ({
    key: i,
    name: `Edward ${i}`,
    age: 32,
    address: `London Park no. ${i}`,
  }));

  const items = [
    {
      key: "1",
      label: "Tab 1",
      children: "Content of Tab Pane 1",
    },
    {
      key: "2",
      label: "Tab 2",
      children: "Content of Tab Pane 2",
    },
    {
      key: "3",
      label: "Tab 3",
      children: "Content of Tab Pane 3",
    },
  ];

  const tabsOnChange = (key) => {
    console.log(key);
  };

  return (
    <Flex>
      <LeftInfo />
      <Flex vertical style={{ height: "894px", overflow: "hidden" }}>
        <Tabs defaultActiveKey="1" items={items} onChange={tabsOnChange} />
        {/* <Flex>
          <Button type="danger">查询</Button>
        </Flex> */}
        <TableContent>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </Flex>
    </Flex>
  );
};
