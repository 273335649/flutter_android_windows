import React, { useEffect, useId, useRef } from "react";
// import * as Antd from "antd";
import { Flex, Image } from "antd";
import { useImperativeHandle } from "react";
import styles from "./index.less";

const Input = React.forwardRef(
  (
    {
      prefix,
      suffix,
      style,
      className,
      allowClear = {
        clearIcon: <Image preview={false} src={require("@/assets/clear-icon.png")} />,
      },
      onClear,
      onChange,
      readOnly = false,
      errorMessage,
      ...resetProps
    },
    ref,
  ) => {
    const nameId = useId();
    const inputRef = useRef(null);

    // 添加设置值的方法
    const setValue = (val = "") => {
      if (inputRef.current) {
        inputRef.current.value = val;
        onChange?.(val);
      }
    };

    useImperativeHandle(ref, () => ({
      setValue,
      clear: () => {
        if (inputRef.current) {
          inputRef.current.value = "";
          onChange?.("");
        }
      },
    }));

    useEffect(() => {
      let nameFn = function (e) {
        console.log("监听值", e.detail, onChange); // 输出: Hello, world!
        if (!readOnly) {
          onChange?.(e.detail);
        }
      };
      document.addEventListener(nameId, nameFn);
      return () => {
        document.removeEventListener(nameId, nameFn);
      };
    }, [nameId, onChange, readOnly]);

    useEffect(() => {
      if (!resetProps.value) {
        onChange?.("");
      }
    }, [resetProps.value]);

    let clear = allowClear
      ? {
          inputStyle: {
            paddingRight: 24,
          },
          icon: (
            <Flex
              style={{
                position: "absolute",
                right: 5,
                top: 0,
                cursor: "pointer",
                height: "100%",
                justifyContent: "center",
                alignItems: "center",
              }}
              onClick={() => {
                setValue("");
                onClear?.();
              }}
            >
              {allowClear?.clearIcon || <Image preview={false} src={require("@/assets/clear-icon.png")} />}
            </Flex>
          ),
        }
      : { inputStyle: {}, icon: null };

    return (
      <>
        <Flex
          justify={"center"}
          align={"center"}
          className={`${styles["input-content"]} ${className || ""}`}
          style={style}
        >
          {prefix}
          <div
            style={{ width: "100%", height: "100%", position: "relative" }}
            onClick={() => {
              if (readOnly) {
                resetProps.onClick?.();
              }
            }}
          >
            <input
              name={nameId}
              ref={inputRef}
              {...resetProps}
              style={{
                ...resetProps.style,
                ...(readOnly ? { pointerEvents: "none" } : {}),
                ...clear?.inputStyle,
              }}
              className={className ? `ant-input ant-input-outlined ${className}` : `ant-input ant-input-outlined`}
              onChange={(e) => {
                if (!readOnly) {
                  onChange?.(e.target.value);
                }
              }}
            />
            {clear.icon}
          </div>
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
        {resetProps?.["aria-invalid"] && <div className={styles["error"]}>{errorMessage}</div>}
      </>
    );
  },
);

export default Input;
