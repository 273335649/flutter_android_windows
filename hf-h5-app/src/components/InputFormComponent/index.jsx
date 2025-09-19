import React, { useState } from "react";
import { Form, Image } from "antd";
import Input from "@/components/Input";
import { STEP_OPERATE_TYPE } from "@/constants";
import MyUpload from "@/components/MyUpload";

const FormCompType = {
  INPUT: "INPUT",
  UPLOAD: "UPLOAD",
};

/**
 * 录入输入框
 *  */
const InputFormComponent = ({ opType, name, inputProps, ...resetProps }) => {
  const [errorMessage, setErrorMessage] = useState("");
  let compType = FormCompType.INPUT;
  let icon = null;
  let formItemElementProps = {
    rules: [
      {
        required: true,
        message: "请输入",
        validator: (_, value) => {
          if (!value) {
            setErrorMessage("请输入");
            return Promise.reject("请输入");
          }
          setErrorMessage("");
          return Promise.resolve();
        },
      },
    ],
  };
  switch (opType) {
    case STEP_OPERATE_TYPE.SUBJECTIVE.code:
      formItemElementProps = {
        rules: [{ required: false }],
      };
      break;
    case STEP_OPERATE_TYPE.TAKE_PICTURE.code:
      compType = FormCompType.UPLOAD;
      icon = <img src={require("@/assets/upload-camera.png")} />;
      break;
    case STEP_OPERATE_TYPE.VIDEO.code:
      compType = FormCompType.UPLOAD;
      icon = <img src={require("@/assets/upload-camera.png")} />;
      break;
    case STEP_OPERATE_TYPE.IMPORT.code:
      compType = FormCompType.UPLOAD;
      break;
    case STEP_OPERATE_TYPE.TYPE_IN.code:
      break;
    default:
      break;
  }

  return (
    <Form.Item noStyle shouldUpdate>
      {({ getFieldValue }) => {
        return (
          <Form.Item noStyle name={name} {...formItemElementProps} {...resetProps}>
            {compType === FormCompType.UPLOAD ? (
              <MyUpload
                icon={icon}
                fileNum={1}
                fileSize={100}
                fileType={["file-JPG", "file-JPEG", "file-PNG"]}
                getForm={() => {
                  return getFieldValue(name);
                }}
              />
            ) : (
              <Input prefix={null} {...inputProps} errorMessage={errorMessage} />
            )}
          </Form.Item>
        );
      }}
    </Form.Item>
  );
};

export default InputFormComponent;
