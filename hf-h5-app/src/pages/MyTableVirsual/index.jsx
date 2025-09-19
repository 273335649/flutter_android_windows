import React from "react";
import { Button, Flex } from "antd";
import VirtualizedTable from "@/components/VirtualizedTable";
import { fetchData } from "./makeData";

function MyTableVirsual() {
  const columns = React.useMemo(
    () => [
      {
        accessorKey: "id",
        header: "ID",
        size: 160,
      },
      {
        accessorKey: "firstName",
        cell: (info) => info.getValue(),
      },
      {
        accessorFn: (row) => row.lastName,
        id: "lastName",
        cell: (info) => info.getValue(),
        header: () => <span>Last Name</span>,
      },
      {
        accessorKey: "age",
        header: () => "Age",
        size: 50,
      },
      {
        accessorKey: "visits",
        header: () => <span>Visits</span>,
        size: 50,
      },
      {
        accessorKey: "status",
        header: "Status",
      },
      {
        accessorKey: "progress",
        header: "Profile Progress",
        size: 300,
      },
      {
        accessorKey: "createdAt",
        header: "Created At",
        cell: (info) => info.getValue().toLocaleString(),
        size: 200,
      },
      {
        accessorKey: "action",
        header: "操作",
        cell: () => (
          <Flex>
            <Button>合格</Button>
            <Button>不合格</Button>
          </Flex>
        ),
        size: 240,
        fixed: "right",
      },
    ],
    [],
  );
  const fetchFn = fetchData;
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
      <VirtualizedTable columns={columns} fetchData={fetchFn} />
    </Flex>
  );
}

export default MyTableVirsual;
