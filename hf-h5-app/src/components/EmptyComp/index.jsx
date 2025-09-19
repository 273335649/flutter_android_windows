import { Empty } from "antd";
import styles from "./index.module.less";

export const EmptyComp = ({ message }) => {
  return (
    <div className={styles["empty-comp"]}>
      <Empty image={Empty.PRESENTED_IMAGE_SIMPLE} description={message || "暂无数据"} />
    </div>
  );
};
