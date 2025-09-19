import usePopup from "@/hooks/usePopup";

export const useIndexModal = () => {
  const { openPopup } = usePopup();

  const openIndexModal = (page = "positionPage", callback) => {
    /**
     * positionPage 岗位选择
     */
    // 1. 通知Flutter打开全屏容器
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler("openIndexModal", page).then((result) => {
        if (callback && typeof callback === "function") {
          callback(result);
        }
      });
    } else {
      openPopup({
        url: "/modal/JobSelectionModal",
        modalProps: {
          title: "岗位选择",
          onCancel: (result) => {
            if (callback && typeof callback === "function") {
              callback(JSON.stringify(result));
            }
          },
        },
      });
      // message.info("暂不支持切换岗位");
    }
  };
  return {
    openIndexModal,
  };
};
export default useIndexModal;
