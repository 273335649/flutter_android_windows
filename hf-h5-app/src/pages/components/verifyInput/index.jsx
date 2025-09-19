import { Image, Button, message } from "antd";
import Input from "@/components/Input";
import React, { useState, useRef, useCallback, useEffect } from "react";
import { useDebounceFn } from "@/hooks/useDebounceFn";
import { CheckCircleOutlined } from "@ant-design/icons";
import useRequest from "@ahooksjs/use-request";
import { verifyThings, scanSubBoxCode } from "@/services/stepRequisition";
import { THINGS_TYPE } from "@/constants";
import styles from "./index.module.less";

export const VerifyInput = ({ isVerified, onSuccess, thingsType, reqId, ...props }) => {
  const inputRef = useRef(null);
  const [inputValue, setInputValue] = useState(null);
  const { run: verify } = useRequest(verifyThings, {
    manual: true,
    onSuccess: (res) => {
      if (res.success) {
        message.success(res.message);
      } else {
        message.info(res.message);
      }
      inputRef.current?.clear?.();
      setInputValue("");
      onSuccess?.();
    },
  });

  const { run: scanBoxCode } = useRequest(scanSubBoxCode, {
    manual: true,
    onSuccess: (res) => {
      if (res.success) {
        message.success(res.message);
      } else {
        message.info(res.message);
      }
      inputRef.current?.clear?.();
      setInputValue("");
    },
  });

  const handleVerify = useCallback(() => {
    let thingsNo = "";

    if (thingsType === THINGS_TYPE.BOX_CODE) {
      if (!inputValue) return;
      scanBoxCode({
        boxCode: inputValue,
        ...props.data,
      });
      return;
    }

    if (thingsType === THINGS_TYPE.TOOL) {
      thingsNo = "1";
    } else {
      if (!inputValue) return;
      thingsNo = inputValue;
    }
    if (reqId) {
      verify({
        reqId: reqId,
        thingsNo,
      });
    } else {
      message.info("请先去领用！");
    }
  }, [inputValue, reqId, thingsType]);

  const handleVerifyDebounce = useDebounceFn(handleVerify, 500);
  useEffect(() => {
    if (inputValue) {
      handleVerifyDebounce();
    }
  }, [inputValue]);

  if (isVerified && thingsType === THINGS_TYPE.BOX_CODE) {
    return isVerified;
  }

  if (isVerified) {
    return <CheckCircleOutlined style={{ color: "green" }} />;
  }
  return (
    <Input
      ref={inputRef}
      onChange={(v) => {
        setInputValue(v);
      }}
      className={styles.input}
      style={{ width: "100%", height: 35.5 }}
      size="small"
      // prefix={<Image preview={false} src={require("@/assets/chevron-right.png")} />}
      prefix={null}
      suffix={
        <Button
          onClick={() => {
            handleVerify();
          }}
          type="link"
          size="small"
          icon={<CheckCircleOutlined style={{ color: "green" }} />}
        />
      }
      {...props}
    />
  );
};

export default VerifyInput;
