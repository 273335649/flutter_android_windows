import React from "react";
import "./index.less";
const RightTop = ({ title, children, noTip = false }) => {
  return (
    <div className="right-top">
      {/* {!noTip && (
        <div className="top-tips">
          2023-12-05 16:00 一般日志：
          通过记录和总结工作过程中的安全事件和采取的安全措施，进一步了解安全管理，提高员工的安全意识和操作技能。
        </div>
      )} */}
      {title && <div className="right-title">{title}</div>}
      {children}
    </div>
  );
};
export default RightTop;
