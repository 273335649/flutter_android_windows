import React, { createContext, useState, useContext } from "react";

const RefreshContext = createContext();

/**
 * 刷新上下文提供者组件
 * @param {Object} props - 组件属性
 * @param {React.ReactNode} props.children - 子组件
 */
export const RefreshProvider = ({ children }) => {
  // 存储各个表格组件的刷新状态
  const [refreshStates, setRefreshStates] = useState({});

  /**
   * 触发指定表格的刷新
   * @param {string} tableId - 表格唯一标识符
   * @param {Object} data - 可选的刷新数据
   */
  const triggerRefresh = (tableId, data = {}) => {
    setRefreshStates((prev) => ({
      ...prev,
      [tableId]: { timestamp: Date.now(), ...data },
    }));
  };

  /**
   * 清除指定表格的刷新状态
   * @param {string} tableId - 表格唯一标识符
   */
  const clearRefresh = (tableId) => {
    setRefreshStates((prev) => {
      const newStates = { ...prev };
      delete newStates[tableId];
      return newStates;
    });
  };

  return (
    <RefreshContext.Provider value={{ refreshStates, triggerRefresh, clearRefresh }}>
      {children}
    </RefreshContext.Provider>
  );
};

/**
 * 使用刷新上下文的钩子
 */
export const useRefresh = () => {
  const context = useContext(RefreshContext);
  if (!context) {
    throw new Error("useRefresh must be used within a RefreshProvider");
  }
  return context;
};
