import React, { useEffect, useState, useCallback } from "react";
import { Flex, message } from "antd";
import { useModel } from "umi";
import LeftInfo from "@/components/LeftInfo";
import RightTop from "@/components/RightTop";
import "./index.less";
import { getListApi, getUploadInfo } from "@/services/common";
import { readFileRewardAPi } from "@/services/fileReward";
import { useModule } from "@/contexts/ModuleContext";

const FILE_TYPES = [
  {
    id: "techNotice",
    name: "技术通知文件",
    tableCode: "MES_FILE_TECH_NOTICE",
    valueMapKey: "MATERIAL_CODE",
    requiresMaterial: true, // 需要物料代码
  },
  {
    id: "sop",
    name: "工艺文件",
    tableCode: "MES_FILE_SOP",
    valueMapKey: "LINE_ID",
    requiresMaterial: false,
  },
  {
    id: "train",
    name: "培训材料",
    tableCode: "MES_FILE_TRAIN",
    valueMapKey: "LINE_ID",
    requiresMaterial: false,
  },
];

export default () => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null } = initialState;
  const [activeNavIndex, setActiveNavIndex] = useState(0);
  const [activeFileIndex, setActiveFileIndex] = useState(0);
  const [documentUrl, setDocumentUrl] = useState(null);
  const [fileLists, setFileLists] = useState({
    techNotice: [],
    sop: [],
    train: [], // 添加培训材料列表
  });
  const [loading, setLoading] = useState(false);
  const { sharedState } = useModule();
  console.log("sharedState: ", sharedState);

  const activeFileType = FILE_TYPES[activeNavIndex];
  const currentFileList = fileLists[activeFileType.id] || [];
  const activeFile = currentFileList[activeFileIndex];

  // 检查当前文件类型是否需要物料代码
  const requiresMaterialCode = activeFileType.requiresMaterial && !sharedState?.materialCode;

  // 获取文件列表
  const fetchFiles = useCallback(
    async (fileType) => {
      if (!fileType) return;

      // 对于需要物料代码的文件类型，检查是否有物料代码
      if (fileType.requiresMaterial && !sharedState?.materialCode) {
        setFileLists((prev) => ({ ...prev, [fileType.id]: [] }));
        return;
      }

      setLoading(true);
      try {
        const params = {
          current: 1,
          size: 9999,
          tableCode: fileType.tableCode,
          valueMap: {
            [fileType.valueMapKey]: fileType.requiresMaterial ? sharedState?.materialCode : lineId,
          },
          orderMap: { CREATE_TIME: "DESC" },
        };

        const res = await getListApi(params);
        if (res.success) {
          setFileLists((prev) => ({
            ...prev,
            [fileType.id]: res.data?.records || [],
          }));
          // 如果切换到新分类且有文件，重置选中状态
          if (res.data?.records?.length > 0) {
            setActiveFileIndex(0);
            setDocumentUrl("");
          }
        } else {
          message.warning(res.message);
        }
      } catch (error) {
        console.error("获取文件列表失败:", error);
        message.error("获取文件列表失败");
      } finally {
        setLoading(false);
      }
    },
    [sharedState?.materialCode, lineId],
  );

  // 获取文件内容
  const fetchFileImage = useCallback(async (file) => {
    if (!file?.DOC_FILE) {
      setDocumentUrl(null);
      return;
    }
    try {
      const fileData = JSON.parse(file.DOC_FILE);
      const fileName = Object.keys(fileData)[0];

      const res = await getUploadInfo({
        urlType: "getFile",
        fileName: fileName,
      });

      if (res.success) {
        setDocumentUrl(res.data);
      } else {
        message.warning(res.message);
        setDocumentUrl(null);
      }
    } catch (error) {
      console.error("获取文件内容失败:", error);
      setDocumentUrl(null);
    }
  }, []);

  // 标记为已读
  const markAsRead = useCallback(
    async (fileId) => {
      try {
        const params = {
          id: fileId,
          type: activeFileType?.id,
        };
        await readFileRewardAPi(params);

        // 更新本地状态，标记为已读
        setFileLists((prev) => ({
          ...prev,
          [activeFileType.id]: prev[activeFileType.id].map((file) =>
            file.ID === fileId ? { ...file, STATUS: "READ" } : file,
          ),
        }));
      } catch (error) {
        console.error("标记为已读失败:", error);
        message.warning("标记为已读失败");
      }
    },
    [activeFileType],
  );

  const handleNavClick = useCallback((index) => {
    setActiveNavIndex(index);
    setActiveFileIndex(0);
    setDocumentUrl(null);
  }, []);

  const handleFileClick = useCallback(
    (index, fileId) => {
      markAsRead(fileId);
      setActiveFileIndex(index);
    },
    [markAsRead],
  );

  // 监听 activeFileType 变化，获取文件列表
  useEffect(() => {
    fetchFiles(activeFileType);
  }, [activeFileType, fetchFiles]);

  // 监听 sharedState.materialCode 变化，如果是需要物料代码的文件类型则重新获取
  useEffect(() => {
    if (activeFileType.requiresMaterial) {
      fetchFiles(activeFileType);
    }
  }, [sharedState?.materialCode, activeFileType, fetchFiles]);

  // 监听 activeFile 变化，获取文件内容
  useEffect(() => {
    if (activeFile) {
      fetchFileImage(activeFile);
    } else {
      setDocumentUrl(null);
    }
  }, [activeFile, fetchFileImage]);

  // 获取未读文件数量
  const getUnreadCount = (fileList) => {
    return fileList.filter((file) => file.STATUS === "PUBLISHED").length;
  };

  return (
    <Flex gap={12} className="file-management-container">
      <LeftInfo />
      <div className="right-container">
        <RightTop title="作业文件" />
        <div className="job-file">
          {/* 导航列表 */}
          <div className="file-nav">
            {FILE_TYPES.map((item, index) => {
              const unreadCount = getUnreadCount(fileLists[item.id] || []);
              return (
                <div key={item.id} className="item-show">
                  <div
                    className={`nav-item ${index === activeNavIndex ? "item-active" : ""}`}
                    onClick={() => handleNavClick(index)}
                  >
                    {item.name}
                  </div>
                  {unreadCount > 0 && <span className="un-reader">{unreadCount}</span>}
                </div>
              );
            })}
          </div>

          {/* 文件内容区域 */}
          <div className="file-content">
            {requiresMaterialCode ? (
              <div className="no-data-tip">请输入机号通过物料编码查看{activeFileType.name}</div>
            ) : currentFileList.length > 0 ? (
              <>
                <div className="file-list">
                  {currentFileList.map((file, index) => (
                    <div
                      key={file.ID || index}
                      className={`document-item ${index === activeFileIndex ? "item-active" : ""} ${
                        file.STATUS === "PUBLISHED" ? "unread" : ""
                      }`}
                      onClick={() => handleFileClick(index, file?.ID)}
                    >
                      <div className="file-icon">
                        {activeFileIndex === index ? (
                          <img src={require(`@/assets/file-icon-actived.png`)} alt="" />
                        ) : (
                          <img src={require(`@/assets/file-icon.png`)} alt="" />
                        )}
                        {file.STATUS === "PUBLISHED" && <div className="unread-dot"></div>}
                      </div>

                      <span className="ellipsis-multiline">
                        {Object.values(JSON.parse(file?.DOC_FILE || "{}")).join(", ")}
                      </span>
                    </div>
                  ))}
                </div>

                <div className="img-show">
                  {documentUrl ? (
                    <iframe
                      src={documentUrl}
                      style={{ width: "100%", height: "800px", border: "none" }}
                      title="文件预览"
                    ></iframe>
                  ) : (
                    <div className="preview-tip">请点击文件查看预览</div>
                  )}
                </div>
              </>
            ) : (
              <div className="no-data-tip">暂无{activeFileType.name}</div>
            )}
          </div>
        </div>
      </div>
    </Flex>
  );
};
