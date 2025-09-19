# 通用表格刷新机制使用指南

## 概述

本指南介绍了项目中实现的通用表格刷新机制，该机制设计用于解决在各种场景下（如弹窗关闭后、操作成功后等）刷新表格数据的需求。这个机制提供了一种统一、可复用的方式来管理表格数据的刷新，避免了在每个组件中重复编写类似的刷新逻辑。

## 核心组件

### 1. RefreshContext

`RefreshContext`是整个刷新机制的核心，它通过React Context API提供了一个全局的状态管理系统，用于协调不同组件之间的刷新操作。

**主要功能**：
- 维护一个全局的刷新状态映射表`refreshStates`
- 提供`triggerRefresh`方法用于触发特定表格的刷新
- 提供`clearRefresh`方法用于清除特定表格的刷新状态
- 提供`useRefresh`钩子函数供组件使用

### 2. useTableRefresh Hook

`useTableRefresh`是一个封装了表格数据获取和刷新逻辑的自定义Hook，它简化了表格组件的实现，使开发者能够专注于业务逻辑而非刷新机制。

**主要功能**：
- 封装了数据获取API的调用
- 处理表格数据的格式化
- 自动监听外部刷新信号
- 支持依赖项变化时自动刷新数据
- 提供手动刷新方法

## 使用方法

### 1. 基础设置（已完成）

`RefreshProvider`已在`Layout`组件中配置，整个应用都可以访问刷新上下文，无需额外配置。

### 2. 在表格组件中使用

#### 步骤1: 引入useTableRefresh Hook

```javascript
import useTableRefresh from "@/hooks/useTableRefresh";
```

#### 步骤2: 使用Hook获取数据和刷新方法

```javascript
const YourTableComponent = ({ ...props }) => {
  // 使用通用表格刷新Hook
  const {
    data: dataSource, // 表格数据源
    loading,          // 加载状态
    loadData,         // 加载数据方法
    refreshData       // 手动刷新方法
  } = useTableRefresh(
    fetchDataApi,     // 获取数据的API函数
    "TABLE_UNIQUE_ID", // 表格唯一标识符（字符串）
    {
      // 默认请求参数
      param1: value1,
      param2: value2,
      // ...
    },
    {
      // 配置选项
      formatResult: (res) => res.data, // 数据格式化函数
      dependencies: [value1, value2]   // 依赖项数组，当这些值变化时自动刷新数据
    }
  );
  
  // 组件其他逻辑...
};
```

### 3. 在其他组件中触发刷新

在需要触发表格刷新的地方（如弹窗关闭后、操作成功后等），可以使用`useRefresh`钩子来触发特定表格的刷新。

#### 步骤1: 引入useRefresh Hook

```javascript
import { useRefresh } from "@/contexts/RefreshContext";
```

#### 步骤2: 触发刷新

```javascript
const YourComponent = () => {
  const { triggerRefresh } = useRefresh();
  
  const handleSomeAction = () => {
    // 执行某些操作后，触发表格刷新
    triggerRefresh("TABLE_UNIQUE_ID", { 
      // 可选的额外参数，会传递给表格的数据获取函数
      refreshSource: "someAction"
    });
  };
  
  // 组件其他逻辑...
};
```

### 4. 在弹窗中返回刷新信号

当需要在弹窗关闭后触发父页面的表格刷新时，可以在弹窗中使用`closePopup`方法并传递刷新类型。

```javascript
const YourModalComponent = () => {
  const { closePopup } = usePopup();
  
  const handleOk = async () => {
    // 执行弹窗内的确认操作
    await someAction();
    
    // 关闭弹窗并发送刷新信号
    closePopup({ type: "refresh" });
  };
  
  // 组件其他逻辑...
};
```

然后在打开弹窗的父组件中处理这个刷新信号：

```javascript
const ParentComponent = () => {
  const { triggerRefresh } = useRefresh();
  const { openPopup } = usePopup();
  
  const openModal = () => {
    openPopup({
      url: "/modal/yourModal",
      modalProps: {
        // 其他props...
        onCancel: (res) => {
          if (res && res.type === "refresh") {
            // 触发表格刷新
            triggerRefresh("TABLE_UNIQUE_ID");
          }
        },
      },
    });
  };
  
  // 组件其他逻辑...
};
```

## 最佳实践

1. **为表格分配唯一标识符**：确保每个需要刷新的表格都有一个唯一的ID，避免刷新信号冲突

2. **合理设置依赖项**：在`useTableRefresh`的`dependencies`参数中添加会影响数据的变量，确保数据能够及时更新

3. **处理空数据情况**：在`formatResult`中处理可能的空数据情况，避免表格显示错误

4. **避免过度刷新**：仅在必要时触发刷新，避免频繁刷新影响性能

5. **统一使用`useTableRefresh`**：对于所有需要远程数据获取和刷新功能的表格组件，建议统一使用`useTableRefresh`，以保持代码风格一致

## 示例

以`WorkClothesTable`组件为例，展示了如何使用`useTableRefresh`实现表格数据的获取和刷新：

```javascript
import React from "react";
import TableComp from "@/components/TableComp";
import { getRequestedThingsList } from "@/services/stepRequisition";
import { useModule } from "@/contexts/ModuleContext";
import useTableRefresh from "@/hooks/useTableRefresh";
import { THINGS_TYPE } from "@/constants";

const WorkClothesTable = ({ onExecuteClick }) => {
  const { sharedState } = useModule();
  
  // 使用通用表格刷新Hook
  const {
    data: dataSource,
    loading,
    loadData,
    refreshData
  } = useTableRefresh(
    getRequestedThingsList,
    "WORK_CLOTHES_TABLE",
    {
      vin: sharedState.vin,
      thingsType: THINGS_TYPE.FIXTURE,
    },
    {
      formatResult: (res) => res.data,
      dependencies: [sharedState.vin] // 当vin变化时自动刷新数据
    }
  );
  
  // 组件其他逻辑...
};
```

## 常见问题

1. **Q: 为什么我的表格没有刷新？**
   A: 请检查以下几点：
   - 表格组件是否正确使用了`useTableRefresh` Hook
   - 表格ID是否与触发刷新时使用的ID一致
   - 触发刷新的代码是否正确执行
   - 依赖项是否正确设置

2. **Q: 如何在多个地方触发同一个表格的刷新？**
   A: 只需要在需要触发刷新的地方使用`useRefresh`钩子，并传入相同的表格ID即可。

3. **Q: 如何将额外参数传递给数据获取函数？**
   A: 在调用`triggerRefresh`时，可以传入第二个参数，这个参数会被传递给表格的数据获取函数。