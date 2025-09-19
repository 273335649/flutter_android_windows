import React, { useState, useEffect, useCallback } from "react";
import { Modal, Flex, Button, message } from "antd";
import { useSearchParams } from "umi";
import usePopup from "@/hooks/usePopup";
import useRequest from "@ahooksjs/use-request";
import { listVins } from "@/services/productionOrder";

// 工单机号明细选择弹窗
const VinsSelectModal = () => {
  const { closePopup } = usePopup();

  const [searchParams] = useSearchParams();

  const [isModalOpen, setIsModalOpen] = useState(true);
  const [selectedVin, setSelectedVin] = useState(null);

  const { data, run: fetchVins } = useRequest(listVins, {
    manual: true,
  });

  const vinsList = data?.data || [];
  useEffect(() => {
    const workOrderId = searchParams.get("workOrderId");
    const scheduleLogId = searchParams.get("scheduleLogId");
    const stationId = searchParams.get("stationId");
    if (workOrderId && scheduleLogId) {
      fetchVins({ type: searchParams.get("type"), search: workOrderId, scheduleLogId, stationId });
    }
  }, [searchParams, fetchVins]);

  useEffect(() => {
    if (vinsList.length > 0 && !selectedVin) {
      setSelectedVin(vinsList[0]);
    }
  }, [vinsList, selectedVin]);

  const handleOk = useCallback(async () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup(selectedVin);
  }, [selectedVin]);

  const handleCancel = () => {
    setIsModalOpen(false);
    // 1. 通知Flutter关闭全屏容器
    closePopup();
  };

  return (
    <Modal
      width={392}
      className="custom-modal"
      title={searchParams.get("title") || "工单机号明细"}
      open={isModalOpen}
      onCancel={handleCancel}
      footer={[
        <Button
          key="submit"
          onClick={() => {
            handleOk();
          }}
        >
          确认
        </Button>,
      ]}
    >
      <div className="modal-content">
        {vinsList.length > 0 ? (
          <Flex vertical gap={10}>
            {vinsList.map((vin) => (
              <div
                key={vin.vin}
                style={{
                  backgroundColor: selectedVin?.vin === vin.vin ? "#1F5EFF" : "transparent",
                  border: selectedVin?.vin === vin.vin ? "1px solid transparent" : "1px solid #1F5EFF",
                  color: "white",
                  padding: "10px",
                  borderRadius: "5px",
                  cursor: "pointer",
                  flex: "0 0 calc(50% - 5px)", // Two items per row with a gap
                  boxSizing: "border-box",
                  textAlign: "center",
                }}
                onClick={() => setSelectedVin(vin)}
              >
                {vin.vin}
              </div>
            ))}
          </Flex>
        ) : (
          <p>暂无机号数据</p>
        )}
      </div>
    </Modal>
  );
};

export default VinsSelectModal;
