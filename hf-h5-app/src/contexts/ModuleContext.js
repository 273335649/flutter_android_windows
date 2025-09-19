import React, { createContext, useState, useContext, useRef } from "react";

const ModuleContext = createContext();

export const ModuleProvider = ({ children }) => {
  const sharedRef = useRef({});

  const [sharedState, setSharedState] = useState(() => {
    const vin = localStorage.getItem("vin");
    const scheduleLogId = localStorage.getItem("scheduleLogId");
    const carNo = localStorage.getItem("carNo");
    return {
      /* 共享状态 */
      record: null,
      vin: vin || null,
      scheduleLogId: scheduleLogId || null,
      carNo: carNo || null,
      // category: CATEGORY.TESTING, // 是否测试岗位
    };
  });
  const [currentModule, setCurrentModule] = useState(null);
  const updateSharedState = (newState, onlyShared = false) => {
    setSharedState((prev) => ({ ...prev, ...newState }));
    if (!onlyShared) {
      // 将特定字段存储到 localStorage
      localStorage.setItem("vin", newState.vin || "");
      localStorage.setItem("scheduleLogId", newState.scheduleLogId || "");
      localStorage.setItem("carNo", newState.carNo || "");
    }
  };

  const updateSharedRef = (key, value) => {
    sharedRef.current[key] = value;
  };

  const clearSharedState = () => {
    updateSharedState({
      vin: "",
      scheduleLogId: "",
      carNo: "",
    });
  };

  const navigateToModule = (moduleName) => {
    setCurrentModule(moduleName);
  };

  return (
    <ModuleContext.Provider
      value={{
        sharedState,
        updateSharedState,
        clearSharedState,
        sharedRef,
        updateSharedRef,
        currentModule,
        navigateToModule,
      }}
    >
      {children}
    </ModuleContext.Provider>
  );
};

export const useModule = () => useContext(ModuleContext);
