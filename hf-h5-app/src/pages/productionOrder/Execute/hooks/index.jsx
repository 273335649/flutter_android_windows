import usePopup from "@/hooks/usePopup";
import { Button, Flex, message } from "antd";
import { THINGS_AUDIT_STATUS, TABLE_CODE, THINGS_TYPE } from "@/constants";
import { confirmThings } from "@/services/stepRequisition";
import { useRefresh } from "@/contexts/RefreshContext";
import useRequest from "@ahooksjs/use-request";
import styles from "../index.module.less";
import { useCallback } from "react";

// 物品领用相关公共hooks

export const useCommonHooks = (thingsType) => {
  const { triggerRefresh } = useRefresh();
  const { openPopup } = usePopup();

  const { run: confirmRun, loading } = useRequest(confirmThings, {
    manual: true,
  });

  const callbackRefresh = useCallback(() => {
    triggerRefresh(TABLE_CODE.WORK_CLOTHES_TABLE, { source: thingsType });
  }, [thingsType]);

  // 更换
  const onChangeClick = (info) => {
    let { serialNumberList, ...record } = info.row.original;
    openPopup({
      url: "/modal/replaceModal",
      modalProps: {
        ...record,
        serialNumberList,
        onCancel: (arg) => {
          arg && callbackRefresh();
        },
      },
    });
  };

  // 点检
  const onSpotCheck = useCallback(
    (info) => {
      let { serialNumberList, ...record } = info.row.original;
      openPopup({
        url: "/modal/spotCheck",
        modalProps: {
          ...record,
          thingsType,
          serialNumberList,
          onCancel: (arg) => {
            arg && callbackRefresh();
          },
        },
      });
    },
    [thingsType],
  );

  // 确认
  const onSpotOk = (info, formData) => {
    let reqId = formData?.reqId || info.row.original.reqId;
    if (reqId) {
      openPopup({
        modalProps: {
          title: "提示",
          content: "请确认是否已领用至岗位？",
          onOkArg: true,
          footer: { okText: "确定" },
          onCancel: (arg) => {
            if (arg) {
              confirmRun({ reqId }).then((res) => {
                if (res.success) {
                  message.success(res.message || "确认成功！");
                  callbackRefresh();
                } else {
                  message.error(res.message || "确认失败！");
                }
              });
            }
          },
        },
      });
    }
  };

  // 获取表格配置
  const getColumns = () => {
    let cols1 = [
      {
        header: "单位",
        size: 150,
        accessorKey: "unit",
      },
      {
        header: "标准数量",
        size: 150,
        accessorKey: "stdQty",
        cell: (info) => info.getValue() || "0",
      },
      {
        header: "领用数量",
        size: 150,
        accessorKey: "toAuditQty",
        cell: (info) => info.getValue() || "0",
      },
      {
        header: "实际发放数量",
        size: 150,
        accessorKey: "actualQty",
        cell: (info) => info.getValue() || "0",
      },
      {
        header: "批次/序列号",
        size: 150,
        accessorKey: "serialNumberList",
        cell: (info) => {
          return (
            <Flex vertical>
              {!info.getValue()?.length && "-"}
              {info.getValue()?.map((n, i) => (
                <div key={n}>
                  {n}
                  {i < info.getValue().length - 1 && "、"}
                </div>
              ))}
            </Flex>
          );
        },
      },
      {
        header: "审核状态",
        size: 150,
        accessorKey: "reqStatus",
        cell: (info) => THINGS_AUDIT_STATUS[info.getValue()] || "-",
      },
      {
        header: "点检状态",
        size: 150,
        accessorKey: "checkStatus",
        cell: (info) => (info.getValue() ? "已完成" : "未完成"),
      },
      {
        header: "操作",
        size: 332,
        fixed: "right",
        cell: (info) => (
          <div style={{ display: "flex", gap: "8px" }}>
            <Button className={styles["action-button"]} size="small" onClick={() => onChangeClick(info)}>
              更换
            </Button>
            {info.row.original.needConfirm && (
              <Button
                loading={loading}
                className={styles["action-button"]}
                size="small"
                onClick={() => onSpotOk(info, { reqId: info.row.original.reqId })}
              >
                确认
              </Button>
            )}
            {info.row.original.needCheck && (
              <Button className={styles["action-button"]} size="small" onClick={() => onSpotCheck(info)}>
                点检
              </Button>
            )}
          </div>
        ),
      },
    ];
    let cols2 = [
      {
        header: "单位",
        size: 150,
        accessorKey: "unit",
      },
      {
        header: "标准数量",
        size: 150,
        accessorKey: "stdQty",
        cell: (info) => info.getValue() || "0",
      },
      {
        header: "领用数量",
        size: 150,
        accessorKey: "toAuditQty",
        cell: (info) => info.getValue() || "0",
      },
      {
        header: "实际发放数量",
        size: 150,
        accessorKey: "actualQty",
        show: () => thingsType === THINGS_TYPE.MATERIAL,
      },
      {
        header: "审核状态",
        size: 150,
        accessorKey: "reqStatus",
        cell: (info) => THINGS_AUDIT_STATUS[info.getValue()] || "-",
      },
      {
        header: "点检状态",
        size: 150,
        accessorKey: "checkStatus",
        cell: (info) => <>{info.getValue() ? "已完成" : "未完成"}</>,
      },
      {
        header: "操作",
        size: 332,
        fixed: "right",
        cell: (info) => (
          <div style={{ display: "flex", gap: "8px" }}>
            {info.row.original.needConfirm && (
              <Button loading={loading} className={styles["action-button"]} size="small" onClick={() => onSpotOk(info)}>
                确认
              </Button>
            )}
            {info.row.original.needCheck && (
              <Button className={styles["action-button"]} size="small" onClick={() => onSpotCheck(info)}>
                点检
              </Button>
            )}
          </div>
        ),
      },
    ];
    let cols = cols1;
    if (thingsType === THINGS_TYPE.TOOL || thingsType === THINGS_TYPE.MATERIAL) {
      cols = cols2;
    }
    return cols;
  };

  return {
    onSpotCheck,
    onChangeClick,
    getColumns,
  };
};
