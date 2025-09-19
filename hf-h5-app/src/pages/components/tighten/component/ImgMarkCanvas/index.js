import React, { useRef, useState, useImperativeHandle, forwardRef, useEffect } from "react";
import { getUploadInfo } from "@/services/common";
import useRequest from "@ahooksjs/use-request";
import styles from "./index.less";

const ImgMarkCanvas = forwardRef(
  ({ imgSrc, points = [], setPoints, activePoint = 0, style, disabled = false }, ref) => {
    const [activeIdx, setActiveIdx] = useState(null); // 当前激活的圆点索引
    const imgRef = useRef(null);
    const [imgDimensions, setImgDimensions] = useState({ width: 0, height: 0 });

    const { data: res, run } = useRequest(getUploadInfo, {
      manual: true,
    });

    useEffect(() => {
      run({
        urlType: "getFile",
        fileName: Object.values(JSON.parse(imgSrc || "{}")).toString(),
      });
    }, [imgSrc]);
    useEffect(() => {
      setActiveIdx(activePoint);
    }, [activePoint]);

    useImperativeHandle(ref, () => ({
      getPoints: () => points,
    }));

    // 处理图片点击
    const handleImgClick = (e) => {
      const rect = imgRef.current.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 100;
      const y = ((e.clientY - rect.top) / rect.height) * 100;
      setPoints && setPoints([...points, { x, y }]);
    };

    // 删除圆点
    const handleDelete = (idx) => {
      setPoints && setPoints(points.filter((_, i) => i !== idx));
      setActiveIdx(null);
    };

    let imgHeight = style?.height || "464px";
    return (
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          position: "relative",
          width:
            imgDimensions.height > 0
              ? `${(imgDimensions.width / imgDimensions.height) * parseFloat(imgHeight)}px`
              : "684px",
          overflow: "hidden", // 限制超出图片区域的内容不显示
          ...style,
          height: imgHeight,
        }}
      >
        <img
          ref={imgRef}
          src={res?.data || ""}
          alt="bgt"
          draggable={false}
          style={{
            width: "auto",
            height: "100%",
            objectFit: "cover",
            display: "block",
            userSelect: "none",
            WebkitUserSelect: "none",
            MozUserSelect: "none",
            msUserSelect: "none",
            cursor: disabled ? "default" : "pointer",
          }}
          onClick={disabled ? undefined : handleImgClick}
          onLoad={(e) => setImgDimensions({ width: e.target.naturalWidth, height: e.target.naturalHeight })}
        />
        {/* 渲染圆点（绿色圆点+白色数字） */}
        {points.map((point, idx) => {
          const isActive = activeIdx === idx;
          return (
            <div
              key={idx}
              className={`${disabled && isActive ? styles["active-ani"] : ""}`}
              style={{
                position: "absolute",
                left: `${point.x}%`,
                top: `${point.y}%`,
                transform: "translate(-50%, -50%)",
                zIndex: 2,
                cursor: disabled ? "default" : "pointer",
                width: 36,
                height: 36,
                background: isActive ? "#6DBD45" : "#0090F5", // 绿色
                borderRadius: "50%",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                boxShadow: isActive ? "0 0 0 4px #1890ff" : "0 2px 8px rgba(0,0,0,0.15)",
                userSelect: "none",
              }}
              onClick={
                disabled
                  ? undefined
                  : (e) => {
                      e.stopPropagation();
                      if (activeIdx === idx) {
                        handleDelete(idx);
                      } else {
                        setActiveIdx(idx);
                      }
                    }
              }
            >
              <span
                style={{
                  color: "#fff",
                  userSelect: "none",
                  lineHeight: 1,
                  pointerEvents: disabled ? "none" : "auto",
                }}
              >
                {idx + 1}
              </span>
            </div>
          );
        })}
      </div>
    );
  },
);

export default ImgMarkCanvas;
