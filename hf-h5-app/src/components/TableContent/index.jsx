import { Flex } from "antd";

const TableContent = ({ children, style }) => (
  <Flex style={{ margin: "18px 16px 0 16px", flex: 1, overflow: "auto", ...style }}>{children}</Flex>
);
export default TableContent;
