import { Flex } from "antd";
import { useEffect, useState } from "react";
import styles from "./index.less";

const RowSelect = ({ info, addSelect, removeSelect, initActive }) => {
  return (
    <Flex
      justify={"center"}
      onClick={() => {
        const newActive = !initActive;
        if (newActive) {
          addSelect(info);
        } else {
          removeSelect(info);
        }
      }}
    >
      <div className={styles.select}>{initActive && <div className={styles.selected}></div>}</div>
    </Flex>
  );
};

export default RowSelect;
