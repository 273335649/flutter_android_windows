import React, { useEffect, useState } from "react";
import LeftInfo from "@/components/LeftInfo";
import { Flex, message, Tooltip, Modal, Spin } from "antd";
import { useModel } from "umi";
import RightTop from "@/components/RightTop";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { readFileRewardAPi } from "@/services/fileReward";
import { getUploadInfo, getListApi } from "@/services/common";
import { FileTextOutlined } from "@ant-design/icons";

export default () => {
  const { initialState = {} } = useModel("@@initialState");
  const { userInfo = {} } = initialState;
  const [dataSource, setDataSource] = useState([]);
  const [previewVisible, setPreviewVisible] = useState(false);
  const [fileUrl, setFileUrl] = useState("");
  const [loading, setLoading] = useState(false);
  const [fileName, setFileName] = useState("");

  const columns = [
    {
      header: "序号",
      size: 70,
      accessorKey: "ID",
      cell: ({ row }) => {
        return <div>{row.index + 1}</div>;
      },
    },
    {
      header: "标题",
      size: 286,
      accessorKey: "TITLE",
    },
    {
      header: "附件",
      accessorKey: "DOC_FILE",
      size: 287,
      cell: ({ row }) => {
        const reqContent = row.original.DOC_FILE;
        const fileName = reqContent ? Object.values(JSON.parse(reqContent)).toString() : "";

        return reqContent ? (
          <Tooltip title={fileName}>
            <div
              className="file-attachment"
              onClick={() => {
                handleFileClick(reqContent, row.original);
              }}
            >
              <FileTextOutlined style={{ marginRight: 8, color: "#1890ff" }} />
              {fileName.length > 20 ? `${fileName.substring(0, 20)}...` : fileName}
            </div>
          </Tooltip>
        ) : (
          "-"
        );
      },
    },
    {
      header: "类型",
      accessorKey: "TYPE",
      size: 139,
      cell: ({ row }) => {
        return <span style={{ color: `${row.original?.TYPE___C}` }}>{row.original.TYPE___L}</span>;
      },
    },
    {
      header: "阅读状态",
      accessorKey: "STATUS___L",
      size: 144,
      cell: ({ row }) => {
        return <span style={{ color: `${row.original?.STATUS___C}` }}>{row.original.STATUS___L}</span>;
      },
    },
    {
      header: "创建人",
      accessorKey: "CREATE_NAME",
      size: 128,
    },
    {
      header: "创建时间",
      accessorKey: "CREATE_TIME",
      size: 288,
    },
  ];

  const getLogList = () => {
    const params = {
      current: 1,
      size: 9999,
      tableCode: "MES_FILE_REWARD_PUNISH",
      valueMap: { USER_ID: userInfo?.userId },
      orderMap: { CREATE_TIME: "DESC" },
    };
    getListApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setDataSource(data?.records);
      } else {
        message.warning(res.message);
      }
    });
  };

  const handleFileClick = (fileData, rowData) => {
    setLoading(true);
    const fileName = Object.values(JSON.parse(fileData || "{}")).toString();
    setFileName(fileName);

    getUploadInfo({
      urlType: "getFile",
      fileName: Object.keys(JSON.parse(fileData || "{}")).toString(),
    })
      .then((res) => {
        if (res.success) {
          setFileUrl(res.data);
          setPreviewVisible(true);
          readFile(rowData);
        } else {
          message.error("获取文件失败");
        }
        setLoading(false);
      })
      .catch(() => {
        message.error("获取文件失败");
        setLoading(false);
      });
  };

  //修改成已读状态
  const readFile = (val) => {
    const params = {
      id: val?.ID,
      type: "punish",
    };
    readFileRewardAPi(params).then((res) => {
      if (res.success) {
        getLogList();
      } else {
        message.warning(res.message);
      }
    });
  };

  const handleCancel = () => {
    setPreviewVisible(false);
    setFileUrl("");
  };

  useEffect(() => {
    getLogList();
  }, []);

  return (
    <Flex>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"人员信息"} />
        <TableContent>
          <TableComp columns={columns} dataSource={dataSource} />
        </TableContent>
      </div>

      <Modal
        className="custom-modal"
        open={previewVisible}
        title={fileName}
        onCancel={handleCancel}
        width="80%"
        footer={null}
      >
        <Spin spinning={loading}>
          <div style={{ height: 500 }}>
            {fileUrl && <iframe src={fileUrl} title="文件预览" frameBorder="0" width="100%" height="100%" />}
          </div>
        </Spin>
      </Modal>
    </Flex>
  );
};
