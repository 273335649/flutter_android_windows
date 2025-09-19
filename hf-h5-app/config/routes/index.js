/**
 * 路由
 */
import modals from "./modals";

const index = [
  {
    path: "/",
    redirect: "/home",
  },
  {
    name: "首页",
    path: "/home",
    component: "@/pages/Home",
  },
  {
    name: "工单",
    path: "/productionOrder",
    component: "@/pages/productionOrder",
  },
  
  {
    name: "巡检",
    path: "/patrol",
    component: "@/pages/patrolInspection",
  },

  {
    name: "成品检验",
    path: "/inspection",
    component: "@/pages/patrolInspection",
  },
  {
    name: "返修",
    path: "/repair",
    component: "@/pages/Repair",
  },
  {
    name: "权限演示",
    path: "/access",
    component: "@/pages/Access",
  },
  {
    name: "打印",
    path: "/UtilsModule",
    component: "@/pages/UtilsModule",
  },
  {
    name: "表格",
    path: "/MyTable",
    component: "@/pages/MyTable",
  },
  {
    name: "虚拟表格",
    path: "/MyTableVirsual",
    component: "@/pages/MyTableVirsual",
  },
  {
    name: "设备",
    path: "/device",
    component: "@/pages/device",
  },
  {
    name: "作业文件",
    path: "/jobFile",
    component: "@/pages/JobFile",
  },
  {
    name: "工具箱",
    path: "/toolBox",
    component: "@/pages/ToolBox",
  },
  {
    name: "人员奖惩",
    path: "/personnelRewardPunishment",
    component: "@/pages/personnelRewardPunishment",
  },
  {
    name: "日志清单",
    path: "/logPage",
    component: "@/pages/logPage",
  },
  {
    path: '/modal',
    component: '@/layouts/modalLayout',
    routes: modals,
  },
  {
    name: "呼叫",
    path: "/andonCall",
    component: "@/pages/AndonCall",
  },
  {
    name: "响应",
    path: "/andonResponse",
    component: "@/pages/AndonResponse",
  },
  {
    name: "404 ",
    path: "/*",
    component: "@/pages/404",
  },
];

export default index;
