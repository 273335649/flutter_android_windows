import { createColumnHelper, flexRender, getCoreRowModel, useReactTable } from "@tanstack/react-table";
import { useMemo } from "react";
import { px2rem } from "@/utils/common";
import { Spin, Tooltip } from "antd";
import { EmptyComp } from "@/components/EmptyComp";
import useSelect from "./useSelect";
import RowSelect from "./RowSelect";
import styles from "./index.less";

const columnHelper = createColumnHelper();

const TableComp = ({ loading, rowKey, emptyMessage, onItemClick, ...props }) => {
  const { onSelectChange } = props;
  const { addSelect, removeSelect, getSelectList } = useSelect(onSelectChange);
  let columns = props.columns
    ?.filter((item) => {
      if (item.show) {
        return item.show(item);
      }
      return true;
    })
    .map(({ header, accessorKey, size, id, cell, tooltip, fixed }) => {
      return columnHelper.accessor(accessorKey, {
        id: id || accessorKey,
        cell: (info) => (cell ? cell(info) : info.getValue() || "-"),
        size,
        header,
        meta: { fixed },
        tooltip,
      });
    });
  if (props.isSelect) {
    columns = [
      {
        header: "选择",
        size: 56,
        accessorKey: "select",
        cell: (info) => {
          return (
            <RowSelect
              info={info.row.original}
              addSelect={addSelect}
              removeSelect={removeSelect}
              initActive={getSelectList().some((item) => item.key === info.row.original.key)}
            />
          );
        },
      },
      ...columns,
    ];
  }
  const dataList = useMemo(
    () =>
      props.dataSource?.map((item, index) => ({ key: item.key || item[rowKey || "id"] || `row-${index}`, ...item })) ||
      [],
    [props.dataSource, rowKey],
  );

  const table = useReactTable({
    columns,
    data: dataList, //also good to use a fallback array that is defined outside of the component (stable reference)
    getCoreRowModel: getCoreRowModel(),
  });

  const getFixedStyles = (cell) => {
    let fixed = cell.column.columnDef.meta?.fixed;
    if (fixed) {
      return {
        position: "sticky",
        left: fixed === "left" ? 0 : "unset",
        right: fixed === "right" ? 0 : "unset",
        zIndex: fixed ? 1 : "unset",
        borderRight: 0,
      };
    } else {
      return {};
    }
  };
  if (loading) {
    return <Spin spinning={loading} style={{ width: "100%", height: "100%" }} />;
  }
  if (!props.dataSource || props.dataSource?.length === 0) {
    return <EmptyComp message={emptyMessage} />;
  }

  let commonItemsStyle = {
    paddingLeft: "24px",
  };

  return (
    <div className="table-content">
      <table>
        <thead>
          {table.getHeaderGroups().map((headerGroup) => (
            <tr key={headerGroup.id}>
              {headerGroup.headers.map((header, index) => (
                <th
                  key={header.id}
                  style={{
                    width: px2rem(header.getSize()),
                    ...getFixedStyles(header),
                    ...(index === 0 ? {} : commonItemsStyle),
                  }}
                >
                  {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody>
          {table.getRowModel().rows.map((row) => (
            <tr
              key={row.id}
              onClick={() => {
                props.isItemClick && props.isItemClick(row.original);
              }}
            >
              {row.getVisibleCells().map((cell, index) => {
                let cont = flexRender(cell.column.columnDef.cell, cell.getContext());
                return (
                  <td
                    key={cell.id}
                    style={{
                      width: px2rem(cell.column.getSize()),
                      wordBreak: "break-word",
                      ...(getSelectList().some((item) => item.key === row.original.key)
                        ? { background: "#0C358F" }
                        : {}),
                      ...getFixedStyles(cell),
                      ...(props.isSelect ? (index === 0 ? {} : commonItemsStyle) : commonItemsStyle),
                    }}
                  >
                    <div className={styles["text-cont"]}>
                      {cell.column.columnDef.tooltip ? (
                        <Tooltip title={cont}>
                          <>{cont}</>
                        </Tooltip>
                      ) : (
                        cont
                      )}
                    </div>
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
        <tfoot style={{ height: "8px" }}></tfoot>
      </table>
    </div>
  );
};

export default TableComp;
