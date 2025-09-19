import React from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { getRequestedThingsList } from "@/services/stepRequisition";
import { useModule } from "@/contexts/ModuleContext";
import useTableRefresh from "@/hooks/useTableRefresh";
import { TABLE_CODE } from "@/constants";
import { useCommonHooks } from "@/pages/productionOrder/Execute/hooks";

// 辅料
const AuxiliaryTable = ({ thingsType }) => {
  const { sharedState } = useModule();
  const { getColumns } = useCommonHooks(thingsType);

  const onSelectChange = (selectedRowKeys, selectedRows) => {
    console.log("Selected rows:", selectedRows);
    // 这里可以添加处理选中行的逻辑
  };

  // 使用通用表格刷新Hook
  const { data: dataSource, loading } = useTableRefresh(
    getRequestedThingsList,
    TABLE_CODE.WORK_CLOTHES_TABLE,
    {
      vin: sharedState.vin,
      thingsType,
    },
    {
      formatResult: (res) => res.data,
      dependencies: [sharedState.vin], // 当vin变化时自动刷新数据
    },
  );

  const columns = [
    {
      header: "序号",
      size: 70,
      cell: ({ row }) => row.index + 1,
    },
    {
      header: "辅料名称",
      size: 150,
      accessorKey: "thingsName",
    },
    {
      header: "辅料编码",
      size: 150,
      accessorKey: "thingsCode",
    },
    ...getColumns(),
  ];

  return (
    <TableContent>
      <TableComp columns={columns} loading={loading} dataSource={dataSource} onSelectChange={onSelectChange} />
    </TableContent>
  );
};

export default AuxiliaryTable;
