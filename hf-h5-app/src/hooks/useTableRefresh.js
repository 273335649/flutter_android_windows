import { useState, useEffect, useCallback, useRef } from "react";
import useRequest from "@ahooksjs/use-request";
import { useRefresh } from "@/contexts/RefreshContext";

/**
 * 表格数据获取和刷新的通用Hook
 * @param {Function} fetchDataApi - 获取数据的API函数
 * @param {string} tableId - 表格唯一标识符
 * @param {Object} defaultParams - 默认请求参数
 * @param {Object} options - 配置选项
 * @param {Function} options.formatResult - 数据格式化函数
 * @param {Array} options.dependencies - 依赖项数组，当这些值变化时自动刷新数据
 * @returns {Object} 返回表格所需的数据和方法
 */
export const useTableRefresh = (fetchDataApi, tableId, defaultParams = {}, options = {}) => {
  const { refreshStates, triggerRefresh, clearRefresh } = useRefresh();
  const { formatResult, dependencies = [], ...resetOptions } = options;
  const [refreshKey, setRefreshKey] = useState(0);

  // 创建请求实例
  const requestConfig = {
    manual: true,
    ...(formatResult && { formatResult }),
    ...resetOptions,
  };

  const { data, loading, error, run } = useRequest(fetchDataApi, requestConfig);

  // 加载数据的方法
  const loadData = useCallback(
    (params = {}) => {
      const requestParams = { ...defaultParams, ...params };
      return run(requestParams);
    },
    [run, defaultParams],
  );

  // 手动触发刷新
  const refreshData = useCallback(
    (params = {}) => {
      setRefreshKey((prev) => prev + 1);
      return loadData(params);
    },
    [loadData],
  );

  // 使用useRef存储loadData函数，避免在依赖项变化时重新创建
  const loadDataRef = useRef(loadData);
  useEffect(() => {
    loadDataRef.current = loadData;
  }, [loadData]);

  // 监听外部触发的刷新信号
  useEffect(() => {
    const refreshState = refreshStates[tableId];
    if (refreshState) {
      loadDataRef.current(refreshState.data || {});
      // 清除刷新状态，避免重复刷新
      setTimeout(() => clearRefresh(tableId), 100);
    }
  }, [refreshStates[tableId], clearRefresh, tableId]);

  // 监听依赖项变化，自动刷新数据
  useEffect(() => {
    loadData();
  }, [...dependencies, refreshKey]);

  return {
    data,
    loading,
    error,
    loadData,
    refreshData,
    triggerRefresh: (data = {}) => triggerRefresh(tableId, data),
  };
};

export default useTableRefresh;
