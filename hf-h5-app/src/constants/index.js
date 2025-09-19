/**
 * 静态数据
 */
export const DEFAULT_NAME = "React";

export const BIZ_TYPE = {
  /** 所有工单 */
  ALL: 0,
  /** 标准工单（排除维修） */
  NORMAL: 1,
  /** 维修工单 */
  REPAIR: 2,
};

export const THINGS_TYPE = {
  /**
   * 物料
   */
  MATERIAL: "MATERIAL",
  /**
   * 工具
   */
  TOOL: "TOOL",
  /**
   * 工装
   */
  FIXTURE: "FIXTURE",
  /**
   * 陪试品
   */
  PVS: "PVS",
  /**
   * 检具
   */
  GAUGE: "GAUGE",
  /**
   * 辅料
   */
  AUXILIARY: "AUXILIARY",
  /**
   * 箱码
   */
  BOX_CODE: "BOX_CODE",
};

// 1=正常工单，2=返修工单
export const WORK_ORDER_TYPE = {
  NORMAL: 1,
  REPAIR: 2,
};

export const RESULT_CODE = {
  /** 进入工步操作 */
  STEP: "STEP",
  /** 进入设备点检 */
  EQPT_CHECK: "EQPT_CHECK",
  /** 进入返修工单 */
  REPAIR: "REPAIR",
  /** 技术通知 */
  TECH_NOTICE: "TECH_NOTICE",
  /** 岗位互检 */
  MUTUAL_INSPECT: "MUTUAL_INSPECT",
  /** 巡检 */
  INSP: "INSP",
};
export const CATEGORY = {
  /** 返工 */
  REWORK: "REWORK",
  /** 部装 */
  SUB_ASSEMBLY: "SUB_ASSEMBLY",
  /** 装配 */
  FINAL_ASSEMBLY: "FINAL_ASSEMBLY",
  /** 测试 */
  TESTING: "TESTING",
  /** 附件分箱 */
  ACCESSORY_BOXING: "ACCESSORY_BOXING",
  /** 包装 */
  PACKAGING: "PACKAGING",
};
/**
 * 表格编码
 */
export const TABLE_CODE = {
  /**
   * 物品领用表格等
   */
  WORK_CLOTHES_TABLE: "WORK_CLOTHES_TABLE",
  /**
   * 当前工步信息
   */
  CURRENT_STEP: "CURRENT_STEP",
};

/**
 *  工步类型,ROUTE=工艺路线工步；INSP=巡检;INSE_FINAL=成品检验工步
 */

export const STEP_TYPE_NAME = {
  ROUTE: "工艺路线",
  INSP: "巡检",
  INSE_FINAL: "成品检验",
};

// 操作结果，OK=合格，PASS_OK=让步合格，NG=返修，此时需传返修参数
export const OPERATION_RESULT = {
  /** 合格 */
  OK: "OK",
  /** 让步合格 */
  PASS_OK: "PASS_OK",
  /** 返修 */
  NG: "NG",
};

export const THINGS_AUDIT_STATUS = {
  /** 待审核 */
  TO_AUDIT: "待审核",
  /** 审核中 */
  AUDITING: "审核中",
  /** 已审核 */
  AUDITED: "已审核",
  /** 驳回 */
  REJECT: "驳回",
};

export const STEP_OPERATE_TYPE = {
  /**
   * 主观
   */
  SUBJECTIVE: {
    id: 1,
    name: "主观",
    code: "SUBJECTIVE",
    description: "",
  },
  /**
   * 录入
   */
  TYPE_IN: {
    id: 2,
    name: "录入",
    code: "TYPE_IN",
    description: "录入数值数据，自动OK/NG",
  },
  /**
   * 拍照
   */
  TAKE_PICTURE: {
    id: 3,
    name: "拍照",
    code: "TAKE_PICTURE",
    description: "",
  },
  /**
   * 摄像
   */
  VIDEO: {
    id: 4,
    name: "摄像",
    code: "VIDEO",
    description: "",
  },
  /**
   * 自动
   */
  AUTOMATIC: {
    id: 5,
    name: "自动",
    code: "AUTOMATIC",
    description: "拧紧类设备，拧紧指引，自动传值，根据范围自动OK/NG",
  },
  /**
   * PLC
   */
  PLC: {
    id: 6,
    name: "PLC",
    code: "PLC",
    description: "非标设备，设备通信传数据，自动传值，根据范围自动OK/NG",
  },
  /**
   * 导入
   */
  IMPORT: {
    id: 7,
    name: "导入",
    code: "IMPORT",
    description: "导入文件，人工OK/NG",
  },
  /**
   * 文本
   */
  TEXT: {
    id: 8,
    name: "文本",
    code: "TEXT",
    description: "人工录文本信息，人工OK/NG。",
  },
  /**
   * 公式
   */
  FORMULA: {
    id: 9,
    name: "公式",
    code: "FORMULA",
    description: "根据公式自动计算结果，自动OK/NG",
  },
};
