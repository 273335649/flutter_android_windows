// 运行时配置
import packageInfo from "../package.json";

// 打印当前版本
console.log(
  `%c ${packageInfo.name || "请在package.json添加name字段"}: v${packageInfo.version} `,
  "background: #222; color: #fefefe; border-radius: 2px",
);

export async function render(oldRender) {
  // if (!window.__POWERED_BY_QIANKUN__) {
  //   saveTokenFromUrl();
  // }
  oldRender();
}

function setRemUnit() {
  const clientWidth = document.documentElement.clientWidth || document.body.clientWidth;
  if (!clientWidth) return;
  document.documentElement.style.fontSize = (clientWidth / 1920) * 16 + "px";
}
setRemUnit();
window.addEventListener("resize", setRemUnit);

// 初始化登录信息
export async function getInitialState() {
  let loginInfo = null;
  try {
    const loginInfoString = localStorage.getItem("loginInfo");
    if (process.env.APP_LOCAL === "true" && !loginInfoString) {
      // mock登录
      // loginInfo = (await getUserInfo())?.data;
      // The logic for opening popup is moved to LoginInitializer component
    } else {
      loginInfo = JSON.parse(loginInfoString);
      console.log("一体机登录信息", JSON.stringify(loginInfo));
    }
  } catch (e) {
    console.error("解析登录信息失败:", e);
  }
  return { userInfo: loginInfo, stationId: loginInfo?.stationId || null, lineId: loginInfo?.lineId || null };
}
