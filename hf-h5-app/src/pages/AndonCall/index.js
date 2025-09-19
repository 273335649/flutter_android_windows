import React, { useState, useRef, useEffect } from "react";
import { useModel } from "umi";
import { Flex, message, Tooltip } from "antd";
import LeftInfo from "@/components/LeftInfo";
import RightTop from "@/components/RightTop";
import "./index.less";
import { listAndonTypeApi } from "@/services/andon";
import usePopup from "@/hooks/usePopup";
import { EmptyComp } from "@/components/EmptyComp";
export default () => {
  const { initialState = {} } = useModel("@@initialState");
  const { lineId = null } = initialState;
  const { openPopup } = usePopup();
  const [navCurrent, setNavCurrent] = useState(0);
  const containerRef = useRef(null);
  const [abnormalList, setAbnormalList] = useState([]);
  // 状态分类数据
  const statusList = [{ name: "完结状态" }, { name: "呼叫状态" }, { name: "超时状态" }, { name: "响应状态" }];

  // 处理导航点击
  const handleNavClick = (index, id) => {
    setNavCurrent(index);
    const element = document.getElementById(id);
    if (element && containerRef.current) {
      containerRef.current.scrollTo({
        top: element.offsetTop - containerRef.current.offsetTop,
        behavior: "smooth",
      });
    }
  };
  //列表
  const getAbnormalList = () => {
    const params = {
      isCall: true,
      lineId: lineId,
    };
    listAndonTypeApi(params).then((res) => {
      const { success, data } = res;
      if (success) {
        setAbnormalList(data);
      } else {
        message.warning(res.message);
      }
    });
  };

  useEffect(() => {
    lineId && getAbnormalList();
  }, [lineId]);
  return (
    <Flex gap={12}>
      <LeftInfo />
      <div className="right-container">
        <RightTop title={"安灯呼叫"} />
        <div className="andon-call">
          {/* 导航列表 */}
          <div className="nav-list">
            {abnormalList.map((item, index) => (
              <div
                className={`nav-item ${index === navCurrent ? "nav-item-active" : ""}`}
                key={item.id}
                onClick={() => handleNavClick(index, item.id)}
              >
                <Tooltip placement="topLeft" title={item.name}>
                  {item.name}
                </Tooltip>
              </div>
            ))}
          </div>

          {/* 右侧内容区域 */}
          <div className="abnormal-right">
            <div className="status-list">
              {statusList.map((item, index) => (
                <span key={index}>{item.name}</span>
              ))}
            </div>

            {/* 可滚动区域 */}
            <div className="abnormal-scroll" ref={containerRef}>
              {abnormalList?.length > 0 ? (
                <>
                  {abnormalList?.map((category) => (
                    <div key={category.id} id={category.id} className="abnormal-box">
                      <div className="name">{category.name}</div>
                      <div className="abnormal-list">
                        {category?.eventList.map((item, index) => (
                          <Tooltip title={item?.eventName} key={index}>
                            <div
                              onClick={() => {
                                openPopup({
                                  url: "/modal/callModal",
                                  modalProps: {
                                    title: "确认提示",
                                    ...item,
                                    onCancel: () => {
                                      getAbnormalList();
                                    },
                                  },
                                });
                              }}
                              className={`ellipsis-multiline ${
                                // 0-呼叫 1-响应超时 2-响应 3-完结 4-完结超时
                                item.status === 3
                                  ? " default-color"
                                  : item.status === 2
                                  ? "green-color"
                                  : item.status === 0
                                  ? "yellow-color"
                                  : "red-color"
                              }`}
                            >
                              {item?.eventName}
                            </div>
                          </Tooltip>
                        ))}
                      </div>
                    </div>
                  ))}
                </>
              ) : (
                <EmptyComp />
              )}
            </div>
          </div>
        </div>
      </div>
    </Flex>
  );
};
