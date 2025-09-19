import { useCallback, useRef } from "react";

export const useDebounceFn = (func, wait) => {
  const timerRef = useRef(null);

  return useCallback(
    (...args) => {
      if (timerRef.current) {
        clearTimeout(timerRef.current);
      }

      timerRef.current = setTimeout(() => {
        func.apply(null, args);
      }, wait);
    },
    [func, wait],
  );
};
