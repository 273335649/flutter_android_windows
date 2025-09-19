import React from "react";
import { ConfigProvider } from "antd";
import { useOutlet } from "umi";
import zhCN from "antd/es/locale/zh_CN";

const ModalLayout = () => {
  const outlet = useOutlet();
  return (
    <ConfigProvider locale={zhCN} modal={{ centered: true }}>
      {outlet}
    </ConfigProvider>
  );
};

export default ModalLayout;
