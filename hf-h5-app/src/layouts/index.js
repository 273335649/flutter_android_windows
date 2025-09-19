import { useLocation, useOutlet } from "umi";
import { ConfigProvider } from "antd";
import zhCN from "antd/es/locale/zh_CN";
import "moment/locale/zh-cn";
import { ModuleProvider } from "@/contexts/ModuleContext";
import { RefreshProvider } from "@/contexts/RefreshContext";
import LoginInitializer from "@/components/LoginInitializer";

const Layouts = () => {
  const outlet = useOutlet();
  const { pathname } = useLocation();

  if (pathname.includes("/login")) {
    return outlet;
  }

  return (
    <ConfigProvider
      locale={zhCN}
      theme={{
        token: {
          // Seed Token，影响范围大
          // colorPrimary: "#00b96b",
          // borderRadius: 2,
          // 派生变量，影响范围小
          // colorBgContainer: "#f6ffed",
          Tabs: {
            /* 这里是你的组件 token */
            itemColor: "#FFFFFF",
            itemHoverColor: "#16F1F7",
            itemSelectedColor: "#16F1F7",
            inkBarColor: "#16F1F7",
            titleFontSize: 22,
          },
        },
      }}
      modal={{ centered: true }}
    >
      <RefreshProvider>
        <ModuleProvider>
          <div className={"container"} style={{ paddingLeft: 16, background: "#001030" }}>
            {/* 本地开发跳转页面 */}
            {/* {process.env.NODE_ENV === "development" && (
            <>
              <Link to={"/home"}>Home</Link> &nbsp;&nbsp;
              <Link to={"/UtilsModule"}>UtilsModule</Link> &nbsp;&nbsp; 
              <Link to={"/MyTable"}>MyTable</Link> &nbsp;&nbsp;
              <Link to={"/MyTableVirsual"}>MyTableVirsual</Link> &nbsp;&nbsp;
            </>
          )} */}

            {outlet}
            <LoginInitializer />
          </div>
        </ModuleProvider>
      </RefreshProvider>
    </ConfigProvider>
  );
};

export default Layouts;
