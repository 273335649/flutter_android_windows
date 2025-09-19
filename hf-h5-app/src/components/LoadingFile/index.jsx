import React, { useState } from "react";
import { Modal, Spin } from "antd";
import LoadingImage from "@/components/LoadingImage";
import { getUploadInfo } from "@/services/common";
import useRequest from "@ahooksjs/use-request";

const LoadingFile = ({ width, height, src }) => {
  const [previewVisible, setPreviewVisible] = useState(false);
  const {
    run,
    loading,
    data: res,
    mutate,
  } = useRequest(getUploadInfo, {
    manual: true,
  });
  let fileUrl = res?.data;
  if (!src) {
    return "-";
  }
  if (["pdf", "xls", "xlsx", "word", "doc", "mp4"].some((type) => src.includes(type))) {
    let fileName = "";
    try {
      fileName = Object.values(JSON.parse(src || "{}")).toString();
    } catch (error) {
      fileName = src;
    }
    return (
      <>
        <a
          onClick={() => {
            try {
              run({
                urlType: "getFile",
                fileName: Object.keys(JSON.parse(src || "{}")).toString(),
              });
            } catch (error) {
              mutate({
                data: src,
              });
            }
            setPreviewVisible(true);
          }}
          rel="noreferrer"
        >
          {fileName}
        </a>
        <Modal
          className="custom-modal"
          open={previewVisible}
          title={"文件"}
          onCancel={() => {
            setPreviewVisible(false);
          }}
          width="80%"
          footer={null}
        >
          <Spin spinning={loading}>
            <div style={{ height: 500 }}>
              {fileUrl && <iframe src={fileUrl} title="文件预览" frameBorder="0" width="100%" height="100%" />}
            </div>
          </Spin>
        </Modal>
      </>
    );
  } else {
    return <LoadingImage width={width} height={height} src={src} />;
  }
};

export default LoadingFile;
