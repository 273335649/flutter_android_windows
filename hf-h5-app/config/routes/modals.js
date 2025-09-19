export default [
  {
    path: "/modal/orderModal",
    component: "./ModalPages/orderModal",
    layout: false,
  },
  {
    path: "/modal/baseModal",
    component: "./ModalPages/baseModal",
    layout: false
  },
  // 发动机上线绑定
  {
    path: "/modal/engineBindModal",
    component: "./ModalPages/engineBindModal",
    layout: false
  },
  // 半成品下线
  {
    path: "/modal/productOfflineModal",
    component: "./ModalPages/productOfflineModal",
    layout: false
  },
  // 执行互检
  {
    path: "/modal/crossCheckModal",
    component: "./ModalPages/crossCheckModal",
    layout: false
  },
  // 返修确认
  {
    path: "/modal/repairConfirmModal",
    component: "./ModalPages/repairConfirmModal",
    layout: false
  },
  // 账号登录
  {
    path: "/modal/loginAccount",
    component: "./ModalPages/loginAccount",
    layout: false
  },
  //呼叫
  {
    path: "/modal/callModal",
    component: "./ModalPages/callModal",
    layout: false
  },
  {
    path: "/modal/responseModal",
    component: "./ModalPages/responseModal",
    layout: false
  },
  /**
   * 更换
   */
  {
    path: "/modal/replaceModal",
    component: "./ModalPages/replaceModal",
    layout: false
  },
  //点检
  {
    path: "/modal/spotCheck",
    component: "./ModalPages/spotCheckModal",
    layout: false
  },
  // 上传图片
  {
    path: "/modal/uploadImage",
    component: "./ModalPages/uploadImageModal",
    layout: false,
  },
  // 工步-领用-物品类型，物料工装工具等，关联字典THINGS_TYPE
  {
    path: "/modal/stepRequisition",
    component: "./ModalPages/StepRequisition",
    layout: false
  },
  // 测试数据
  {
    path: "/modal/testData",
    component: "./ModalPages/testDataModal",
    layout: false,
  },
  // 机号选择
  {
    path: "/modal/vinsSelectModal",
    component: "./ModalPages/vinsSelectModal",
    layout: false,
  },
  // 设备报修
  {
    path: "/modal/deviceRepairModal",
    component: "./ModalPages/deviceRepairModal",
    layout: false,
  },
  // 设备点检
  {
    path: "/modal/deviceSpotChectModal",
    component: "./ModalPages/deviceSpotChectModal",
    layout: false,
  },
  // 岗位切换
  {
    path: "/modal/JobSelectionModal",
    component: "./ModalPages/JobSelectionModal",
    layout: false,
  },
];
