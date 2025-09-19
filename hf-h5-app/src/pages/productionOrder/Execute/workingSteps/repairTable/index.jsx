import React, { useRef, useState } from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Flex, Image, Carousel, Button } from "antd";
import VerifyInput from "@/pages/components/verifyInput";
import chevronLeft from "@/assets/chevron-left_3.png";
import chevronRight from "@/assets/chevron-right_3.png";
import RightTop from "@/components/RightTop";
import styles from "./index.module.less";
import { useModule } from "@/contexts/ModuleContext";
import { CATEGORY } from "@/constants";
import LoadingImage from "@/components/LoadingImage";

const RepairTable = ({ stepData, stepLoading }) => {
  const { sharedState } = useModule();

  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const carouselRef = useRef(null);

  const handlePrev = () => {
    carouselRef.current?.prev();
  };

  const handleNext = () => {
    carouselRef.current?.next();
  };
  const columns = [
    // {
    //   header: "序号",
    //   size: 56,
    //   accessorKey: "sequenceNumber",
    // },
    {
      header: "编码",
      size: 100,
      accessorKey: "thingsCode",
    },
    {
      header: "物料名称",
      size: 160,
      accessorKey: "thingsName",
    },
    {
      header: "检验类型",
      size: 180,
      accessorKey: "thingsType",
    },
    {
      header: "版本号",
      size: 120,
      accessorKey: "thingsVersion",
    },
    {
      header: "数量",
      size: 150,
      accessorKey: "stdQty",
    },
    {
      header: "批次/序列号",
      size: 300,
      accessorKey: "thingsNo",
      cell: (info) => (
        <VerifyInput
          className={styles.input}
          style={{ width: 200, height: 35.5 }}
          isVerified={info.row.original.isVerified}
          thingsType={info.row.original.thingsType}
          reqId={info.row.original.vinStepThingsId || info.row.original.id}
        />
      ),
    },
  ];

  const statusType = sharedState.category === CATEGORY.TESTING ? "isTest" : "isNormal";

  let maxObj = new Map([
    [
      "isTest",
      {
        contStyle: {
          width: "100%",
        },
        itemStyle: {
          width: "263px",
          margin: "0 7px",
        },
        len: 5,
        showRight: false,
      },
    ],
    [
      "isNormal",
      {
        contStyle: {},
        itemStyle: {
          width: "220px",
          margin: "0 7px",
        },
        len: 2,
        showRight: true,
      },
    ],
  ]);

  const { contStyle, len, showRight, itemStyle } = maxObj.get(statusType);

  // 图片处理
  const getImages = () => {
    let imgs = [];
    let arr = stepData?.stepFiles || [];
    try {
      if (arr.length > 0) {
        arr.forEach((item) => {
          let arrObj = JSON.parse(item.fileInfo);
          let keys = Object.keys(arrObj || "{}");
          if (keys?.length > 0) {
            imgs = [...imgs, ...(keys.map((key) => JSON.stringify({ [key]: arrObj[key] })) || [])];
          } else {
            imgs = [...imgs, item.fileInfo];
          }
        });
      }
    } catch (error) {}

    return imgs;
  };

  let imgs = getImages();

  return (
    <>
      <Flex className={styles.content}>
        {imgs?.length > 0 && (
          <div className={styles["carousel-container"]} style={contStyle}>
            <Carousel
              dots={false}
              arrows={false}
              infinite={true}
              beforeChange={(oldIndex, newIndex) => setCurrentImageIndex(newIndex)}
              initialSlide={currentImageIndex}
              ref={carouselRef}
            >
              {Array.from({ length: Math.ceil(imgs?.length || 0 / len) }).map((_, slideIndex) => (
                <div key={slideIndex}>
                  <Flex>
                    {imgs?.slice(slideIndex * len, slideIndex * len + len).map((v, imgIndex) => {
                      return <LoadingImage key={imgIndex} style={{ height: "228px", ...itemStyle }} src={v} />;
                    })}
                  </Flex>
                </div>
              ))}
            </Carousel>
            {imgs?.length > 1 && (
              <div className={styles["carousel-controls"]}>
                <Button onClick={handlePrev}>
                  <Image src={chevronLeft} preview={false} />
                </Button>
                <Button onClick={handleNext}>
                  <Image src={chevronRight} preview={false} />
                </Button>
              </div>
            )}
          </div>
        )}
        {showRight &&
          (sharedState.isInsp ? (
            <Flex vertical style={{ flex: 1, overflow: "hidden" }}>
              <RightTop title="工具/工装/检具" notip={true} />
              <TableContent style={{ margin: "5px 5px 10px 10px", minWidth: 914 }}>
                <TableComp columns={columns} dataSource={stepData?.fixtures || []} loading={stepLoading} />
              </TableContent>
            </Flex>
          ) : (
            <Flex vertical style={{ flex: 1, overflow: "hidden" }}>
              <RightTop title="物料" noTip={true} />
              <TableContent style={{ margin: "5px 5px 10px 10px", minWidth: 914 }}>
                <TableComp columns={columns} dataSource={stepData?.materials || []} loading={stepLoading} />
              </TableContent>
            </Flex>
          ))}
      </Flex>
    </>
  );
};

export default RepairTable;
