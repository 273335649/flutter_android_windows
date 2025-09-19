import React, { useCallback, useEffect, useState } from "react";
import { Modal, Row, Col, Button, Space, Form, message } from "antd";
import common from "../../common.less";
import useRequest from "@ahooksjs/use-request";
import { getSubBoxList, submitSubBox } from "@/services/stepRequisition";

const VIN_SUB_BOX_STATUS = {
  /**
   *  初始化
   */
  INITIAL: "INITIAL",
  /**
   *   执行中
   */
  EXECUTING: "EXECUTING",
  /**
   *   已执行
   */
  EXECUTED: "EXECUTED",
};

const ModalContent = ({ dataSource, handleOk, loading }) => {
  const [activeId, setActiveId] = useState(null);

  return (
    <Row className="row-btn">
      <Col span={24} className="container">
        <Space wrap>
          {dataSource?.map((v, i) => (
            <Button
              key={i}
              disabled={VIN_SUB_BOX_STATUS.EXECUTED === v.status}
              style={
                VIN_SUB_BOX_STATUS.EXECUTED === v.status
                  ? { background: "#1f5eff" }
                  : activeId === v.id
                  ? { background: "#00BFFF", borderColor: "#00BFFF" } // Active style
                  : {}
              }
              type="primary"
              onClick={() => {
                if (VIN_SUB_BOX_STATUS.EXECUTED !== v.status) {
                  setActiveId(v.id);
                }
              }}
            >
              {`${v.boxSerialNo}号箱`}
            </Button>
          ))}
        </Space>
      </Col>
      <Col
        offset={20}
        span={4}
        style={{
          textAlign: "right",
          marginTop: 52,
        }}
      >
        <Space>
          <Button
            disabled={!activeId}
            hidden={!dataSource?.length}
            loading={loading}
            type="primary"
            onClick={() => {
              handleOk?.(activeId);
            }}
          >
            提交
          </Button>
        </Space>
      </Col>
    </Row>
  );
};

// 选择分箱箱号
const useContainerNumModal = (props) => {
  const { run: check, loading } = useRequest(submitSubBox, {
    manual: true,
  });

  const { run: getData } = useRequest(getSubBoxList, {
    manual: true,
    formatResult: (res) => res.data || res,
    onSuccess: (res) => {
      if (!res.success) {
        res.message && message.info(res.message);
      }
    },
  });

  const handleOk = useCallback(
    (selectId) => {
      if (selectId) {
        check({
          id: selectId,
        }).then((res) => {
          if (res.success) {
            message.success(res.message, 0.5, () => {
              props.onOk?.(selectId);
              Modal.destroyAll();
            });
          } else {
            message.info(res.message);
          }
        });
      }
    },
    [props],
  );
  const handleCancel = () => {
    Modal.destroyAll();
    // 1. 通知Flutter关闭全屏容器
  };
  const openNumModal = async ({ vin, lineId, stationId }) => {
    if (vin && lineId && stationId) {
      const dataList = await getData({ vin, lineId, stationId });
      let dataSource = dataList?.message ? [] : dataList;
      if (dataSource.length > 0) {
        Modal.confirm({
          closable: true,
          className: `${common.content} custom-modal`,
          icon: null,
          onCancel: handleCancel,
          footer: false,
          width: 800,
          centered: true,
          content: <ModalContent dataSource={dataSource} handleOk={handleOk} loading={loading} />,
        });
      } else {
        props.onOk?.();
      }
    }
  };
  return [openNumModal];
};

export default useContainerNumModal;
