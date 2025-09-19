import React, { useRef, useEffect, useId, useCallback } from "react";

const usePopup = () => {
  const handleMessageRef = React.useRef(null);
  const channel = new BroadcastChannel(`popup_channel`);

  const openPopup = useCallback(
    ({ url, modalProps }) => {
      const currentOrigin = window.location.origin;
      let openUrl = url?.indexOf("http") === 0 ? url : `${currentOrigin}${url || "/modal/baseModal"}`;
      if (modalProps) {
        if (modalProps.footer) {
          modalProps.footer = JSON.stringify(modalProps.footer);
        }
        const filteredProps = Object.fromEntries(
          // null转换为空字符串
          Object.entries(modalProps).map(([key, value]) => [key, value === null ? "" : value]),
        );
        const params = new URLSearchParams(filteredProps).toString();
        openUrl = `${openUrl}?${params}`;

        if (modalProps?.onCancel) {
          console.log("注册");
          handleMessageRef.current = (event) => {
            if (event.data.type === "closeFullscreenPopup") {
              // 在这里处理回调刷新或其他自定义操作
              console.log("收到关闭全屏弹窗事件");
              // 例如：刷新页面
              // window.location.reload();
              channel.removeEventListener("message", handleMessageRef.current);
              let resData = "";
              try {
                resData = JSON.parse(event.data?.data);
              } catch (error) {
                resData = event.data?.data;
              }
              modalProps.onCancel(resData);
            }
          };
          channel.addEventListener("message", handleMessageRef.current);
        }
      }
      // 1. 通知Flutter打开全屏容器
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler("openFullscreenPopup", openUrl);
      } else {
        console.log("openFullscreenPopup");
        // 备用方案：普通弹窗
        window.open(openUrl, "_blank");
      }
    },
    [channel],
  );
  const closePopup = useCallback(
    (arg) => {
      if (window.flutter_inappwebview) {
        const postData = typeof arg === "object" ? JSON.stringify(arg) : arg || "";
        channel?.postMessage({ type: "closeFullscreenPopup", data: postData });
        window.flutter_inappwebview.callHandler("closeFullscreenPopup", arg || "");
      } else {
        // window.postMessage({ type: "closeFullscreenPopup" }, window.location.origin);
        const postData = typeof arg === "object" ? JSON.stringify(arg) : arg || "";
        channel?.postMessage({ type: "closeFullscreenPopup", data: postData });
        window.close();
      }
    },
    [channel],
  );

  useEffect(() => {
    // 组件卸载时移除监听
    return () => {
      handleMessageRef.current && channel.removeEventListener("message", handleMessageRef.current);
    };
  }, [handleMessageRef.current, channel]);

  return {
    openPopup,
    closePopup,
  };
};

export default usePopup;
