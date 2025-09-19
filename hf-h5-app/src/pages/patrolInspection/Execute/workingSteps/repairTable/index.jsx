import React, { useRef, useState } from "react";
import TableContent from "@/components/TableContent";
import TableComp from "@/components/TableComp";
import { Flex, Image, Carousel, Button } from "antd";
import Input from "@/components/Input";
import chevronLeft from "@/assets/chevron-left_3.png";
import chevronRight from "@/assets/chevron-right_3.png";
import RightTop from "@/components/RightTop";
import styles from "./index.module.less";

const RepairTable = () => {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const carouselRef = useRef(null);
  const images = [
    require("@/assets/tool-img0.png"),
    require("@/assets/tool-img1.png"),
    require("@/assets/tool-img2.png"),
    require("@/assets/tool-img3.png"),
    require("@/assets/tool-img4.png"),
    require("@/assets/tool-img5.png"),
    require("@/assets/tool-img6.png"),
    require("@/assets/tool-img7.png"),
    require("@/assets/tool-img8.png"),
    require("@/assets/tool-img9.png"),
    require("@/assets/tool-img10.png"),
    require("@/assets/tool-img11.png"),
  ];

  const handlePrev = () => {
    carouselRef.current.prev();
  };

  const handleNext = () => {
    carouselRef.current.next();
  };
  const columns = [
    {
      header: "编码",
      size: 100,
      accessorKey: "repairOrderNumber",
    },
    {
      header: "物料名称",
      size: 160,
      accessorKey: "productionOrderNumber",
    },
    {
      header: "检验类型",
      size: 180,
      accessorKey: "sapOrderNumber",
    },
    {
      header: "数量",
      size: 150,
      accessorKey: "statusCode",
    },
    {
      header: "校验",
      size: 300,
      accessorKey: "plannedTime",
      cell: () => (
        <Input
          className={styles.input}
          style={{ width: 200, height: 35.5 }}
          size="small"
          allowClear={{
            clearIcon: <Image preview={false} src={require("@/assets/chevron-right.png")} />,
          }}
          prefix={<Image preview={false} src={require("@/assets/chevron-right.png")} />}
        />
      ),
    },
  ];

  const dataSource = Array.from({ length: 2 }).map((_, i) => ({
    key: i,
    sequenceNumber: i + 1,
    repairOrderNumber: `R${1000 + i}`,
    productionOrderNumber: `物料名称 ${i}`,
    sapOrderNumber: `检验类型 ${i % 2 === 0 ? "A" : "B"}`,
    model: `V${i % 5}`,
    statusCode: Math.floor(Math.random() * 100) + 1,
    plannedTime: `批次/序列号 ${2023000 + i}`,
  }));

  const statusType = "isTest";
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
        },
        len: 2,
        showRight: true,
      },
    ],
  ]);

  const { contStyle, len, showRight, itemStyle } = maxObj.get(statusType);

  return (
    <>
      <Flex className={styles.content}>
        <div className={styles["carousel-container"]} style={contStyle}>
          <Carousel
            dots={false}
            arrows={false}
            infinite={true}
            beforeChange={(oldIndex, newIndex) => setCurrentImageIndex(newIndex)}
            initialSlide={currentImageIndex}
            ref={carouselRef}
          >
            {Array.from({ length: Math.ceil(images.length / len) }).map((_, slideIndex) => (
              <div key={slideIndex}>
                <Flex>
                  {images.slice(slideIndex * len, slideIndex * len + len).map((imgSrc, imgIndex) => (
                    <Image key={imgIndex} style={{ height: "228px", ...itemStyle }} src={imgSrc} preview={true} />
                  ))}
                </Flex>
              </div>
            ))}
          </Carousel>
          <div className={styles["carousel-controls"]}>
            <Button onClick={handlePrev}>
              <Image src={chevronLeft} preview={false} />
            </Button>
            <Button onClick={handleNext}>
              <Image src={chevronRight} preview={false} />
            </Button>
          </div>
        </div>
        {showRight && (
          <Flex vertical style={{ overflow: "hidden" }}>
            <RightTop title="工具/工装/检具" notip={true} />
            <TableContent style={{ margin: "5px 5px 10px 10px" }}>
              <TableComp columns={columns} dataSource={dataSource} />
            </TableContent>
          </Flex>
        )}
      </Flex>
    </>
  );
};

export default RepairTable;
