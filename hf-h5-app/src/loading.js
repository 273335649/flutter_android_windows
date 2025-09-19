import { Spin } from "antd";

export default () => {
  return (
    <div
      style={{
        fontSize: 12,
        textAlign: "center",
        paddingTop: 20,
        color: "#999",
      }}
    >
      {/*<span>加载中...</span>*/}
      <Spin spinning={true} />
    </div>
  );
};
