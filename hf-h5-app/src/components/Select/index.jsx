import React, { useState, useEffect } from "react";
import { Menu } from "antd";
import styles from "./index.less";

const Select = ({ options, onChange, value, placeholder, ...resetProps }) => {
  let initialValue = { label: "", key: "" };
  const [selected, setSelected] = useState(initialValue);
  const items = [
    {
      key: "sub1",
      label: selected.label || placeholder || "请选择",
      children: options ? options?.map(({ value, label }) => ({ key: value, label })) : [],
    },
  ];
  const onClick = ({ item, key, keyPath }) => {
    setSelected({ label: options?.find(({ value }) => value === key)?.label, key: key });
    onChange?.([key]);
  };
  useEffect(() => {
    if (!value) {
      setSelected(initialValue);
    }
  }, [value]);

  return (
    <Menu
      className={styles["menu-cont"]}
      onClick={onClick}
      // style={{ width: "100%" }}
      mode="vertical"
      items={items}
      {...resetProps}
    />
  );
};

export default Select;
