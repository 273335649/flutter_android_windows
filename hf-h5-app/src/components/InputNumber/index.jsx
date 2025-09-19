import React, { Fragment, useEffect, useId, useRef } from "react";
// import * as Antd from "antd";
import { Flex, Image } from "antd";
import styles from "./index.less";

export const InputNumber = ({
  prefix,
  suffix,
  style,
  className,
  min = -Infinity,
  max = Infinity,
  step = 1,
  onChange,
  readOnly = false,
  precision,
  ...resetProps
}) => {
  const nameId = useId();
  const inputRef = useRef(null);
  let checkValue = (val) => {
    if (val === "") {
      return "";
    }
    let newValue = parseFloat(val);
    if (isNaN(newValue)) {
      newValue = min;
    }
    if (newValue < min) {
      newValue = min;
    }
    if (newValue > max) {
      newValue = max;
    }
    if (precision === 0) {
      newValue = parseInt(newValue);
    }
    return newValue;
  };
  useEffect(() => {
    let nameFn = function (e) {
      if (!readOnly) {
        onChange?.(checkValue(e.detail));
      }
    };
    document.addEventListener(nameId, nameFn);
    return () => {
      document.removeEventListener(nameId, nameFn);
    };
  }, [nameId, onChange, readOnly]);

  return (
    <Flex justify={"center"} align={"center"} className={`${styles["input-content"]} ${className || ""}`} style={style}>
      {prefix}
      <div
        style={{ width: "100%" }}
        onClick={() => {
          if (readOnly) {
            resetProps.onClick?.();
          }
        }}
      >
        <input
          name={nameId}
          ref={inputRef}
          type="number"
          {...resetProps}
          style={{
            ...resetProps.style,
            ...(readOnly ? { pointerEvents: "none" } : {}),
          }}
          className={className ? `ant-input ant-input-outlined ${className}` : `ant-input ant-input-outlined`}
          onChange={(e) => {
            if (!readOnly) {
              onChange?.(checkValue(e.target.value));
            }
          }}
        />
      </div>
      {/* {allowClear?.clearIcon} */}
      <div
        onClick={() => {
          if (readOnly) {
            resetProps.onClick?.();
          }
        }}
      >
        {suffix}
      </div>
    </Flex>
  );
};

export default InputNumber;
