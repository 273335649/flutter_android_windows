import { Upload, Button, message, Image } from "antd";
import { useState, useEffect, useMemo } from "react";
import { LoadingOutlined } from "@ant-design/icons";
import { useSearchParams } from "@umijs/max";
import { postFileUpload, getUploadInfo } from "@/services/common";

const FILE_ICON_MAP = {
  jpg: "file-JPG",
  gif: "file-gif",
  jpeg: "file-JPEG",
  ppt: "file-ppt",
  txt: "file-txt",
  bmp: "file-bmp",
  doc: "file-doc",
  xls: "file-XLS",
  pdf: "file-pdf1",
  png: "file-PNG",
  unkonw: "file-unknown1",
};

export default (props = {}) => {
  const [searchParams] = useSearchParams();
  const tableCode = searchParams.get("tableCode");

  const {
    value = [],
    onChange,
    fileSize, // 不再设置默认值，在validateFile中处理
    fileNum = 5,
    uploadUrl = "",
    fileTypes = [],
    originProps = {},
    setForm,
    getForm,
    titlestatus,
    propsItem,
    fileType = "",
    icon,
  } = props;

  const [fileList, setFileList] = useState([]);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    const formList = getForm?.();
    if (formList && typeof formList === "string") {
      try {
        const parsedList = JSON.parse(formList);
        const newVal = Object.entries(parsedList).map(([fileName, name]) => ({
          fileName,
          name,
          url: "url",
          uid: `${fileName}-${Date.now()}`,
        }));
        setFileList(newVal);
      } catch (error) {
        console.error("解析文件列表失败:", error);
      }
    }
  }, [getForm]);

  const validateFile = (file) => {
    // 设置默认文件大小限制为500MB
    const maxFileSize = fileSize !== undefined ? fileSize : 500;

    if (fileTypes.length > 0 && !fileTypes.includes(file.type.toLowerCase())) {
      message.error(`请上传 ${fileTypes.join(", ")} 格式的文件`);
      return false;
    }

    if (file.size > maxFileSize * 1024 * 1024) {
      message.error(`文件大小超过限制 ${maxFileSize}MB`);
      return false;
    }

    return true;
  };

  const handleUpload = async (file) => {
    setUploading(true);

    try {
      const formData = new FormData();
      formData.append("file", file);
      const uploadRes = await postFileUpload(formData);
      if (uploadRes.success) {
        return {
          fileName: uploadRes.data,
          name: file.name,
          status: "done",
          url: "url",
          uid: file.uid || `${file.name}-${Date.now()}`,
        };
      } else {
        throw new Error(uploadRes.message || "上传失败");
      }
    } catch (error) {
      console.error("上传错误:", error);
      throw error;
    } finally {
      setUploading(false);
    }
  };

  const beforeUpload = (file, currentFileList) => {
    // 计算已上传文件 + 新选择文件的总数
    const totalFiles = fileList.length + currentFileList.length;

    // 如果已经达到限制，阻止上传
    if (fileList.length >= fileNum) {
      message.error(`文件数量超过限制 ${fileNum}个`);
      return Upload.LIST_IGNORE;
    }

    // 如果新选择的文件会导致总数超过限制，阻止上传
    if (totalFiles > fileNum) {
      message.error(`文件数量超过限制 ${fileNum}个`);
      return Upload.LIST_IGNORE;
    }

    return validateFile(file);
  };

  const customRequest = async ({ file, onSuccess, onError }) => {
    try {
      const newFile = await handleUpload(file);

      setFileList((prev) => {
        const updatedList = [...prev, newFile];

        const formFileList = updatedList.reduce((acc, item) => {
          acc[item.fileName] = item.name;
          return acc;
        }, {});
        onChange?.(formFileList);
        return updatedList;
      });

      onSuccess(newFile, file);
      message.success(`${file.name} 上传成功`);
    } catch (error) {
      onError(error);
      message.error(error.message || "上传失败");
    }
  };

  const handlePreview = async (file) => {
    try {
      const res = await getUploadInfo({ urlType: "getFile", fileName: file?.fileName });

      if (res.success) {
        window.open(res.data);
      } else {
        throw new Error(res.message || "获取文件地址失败");
      }
    } catch (error) {
      message.error(error.message || "预览文件失败");
    }
  };

  const handleRemove = (file) => {
    setFileList((prev) => {
      const newList = prev.filter((f) => f.uid !== file.uid);

      const formFileList = newList.reduce((acc, item) => {
        acc[item.fileName] = item.name;
        return acc;
      }, {});

      onChange?.(newList.length === 0 ? undefined : formFileList);

      return newList;
    });
  };

  const itemRender = (originNode, file) => {
    const fileExt = file.name.slice(file.name.lastIndexOf(".") + 1).toLowerCase();
    const iconType = FILE_ICON_MAP[fileExt] || FILE_ICON_MAP.unkonw;

    return (
      <div className="ant-upload-list-item ant-upload-list-item-undefined">{originNode.props.children.slice(1)}</div>
    );
  };

  const uploadProps = useMemo(
    () => ({
      name: "file",
      maxCount: fileNum,
      multiple: fileNum > 1,
      fileList,
      showUploadList: {
        showPreviewIcon: true,
        showRemoveIcon: !props?.disabled,
      },
      beforeUpload,
      itemRender,
      customRequest,
      onPreview: handlePreview,
      onRemove: handleRemove,
      disabled: props?.disabled || (titlestatus && props?.editDisabled),
      ...originProps,
    }),
    [fileList, fileNum, props?.disabled, titlestatus, props?.editDisabled, originProps],
  );

  return (
    <div className="upload-container">
      <Upload {...uploadProps}>
        <Button
          className="upload-btn"
          icon={
            uploading ? (
              <LoadingOutlined spin />
            ) : (
              icon || <img style={{ maxWidth: 24, maxHeight: 24 }} src={require("@/assets/upload-icon.png")} />
            )
          }
        >
          {uploading ? "上传中..." : "上传"}
        </Button>
      </Upload>
    </div>
  );
};
