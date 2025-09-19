import React, { useEffect } from "react";
import { Image, Spin } from "antd";
import { getUploadInfo } from "@/services/common";
import useRequest from "@ahooksjs/use-request";

const LoadingImage = ({ style, width, height, src, ...reset }) => {
  const {
    data: res,
    run,
    loading,
  } = useRequest(getUploadInfo, {
    manual: true,
  });

  useEffect(() => {
    if (src) {
      run({
        urlType: "getFile",
        fileName: Object.keys(JSON.parse(src || "{}")).toString(),
      });
    }
  }, [src]);

  return (
    <Spin spinning={loading}>
      <Image style={{ height: "228px", height, width, ...style }} src={res?.data || ""} preview={true} {...reset} />
    </Spin>
  );
};

export default LoadingImage;
