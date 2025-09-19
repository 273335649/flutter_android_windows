import React from "react";
import { Button, Card, Flex } from "antd";
import TableComp from "@/components/TableComp";

const UtilsTable = () => {
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
      header: "Column 4",
      accessorKey: "address3",
      size: 150,
    },
    {
      header: "Column 5",
      accessorKey: "address4",
      size: 150,
    },
    {
      header: "Column 6",
      accessorKey: "address5",
      size: 150,
    },
    {
      header: "Column 7",
      accessorKey: "address6",
      size: 150,
    },
    { header: "Column 8", accessorKey: "address7" },
    {
      id: "action",
      header: "Action",
      size: 100,
      render: () => {
        return (
          <Flex>
            <Button type={"primary"}>合格</Button>
            <Button type={"danger"}>不合格</Button>
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

  return (
    <Flex
      direction={"column"}
      style={{
        // display: "flex",
        // flexDirection: "column",
        height: "100vh",
      }}
    >
      <Flex>
        <Button type="danger">查询</Button>
      </Flex>
      <TableComp columns={columns} dataSource={dataSource} />
    </Flex>
  );
};

export default UtilsTable;
