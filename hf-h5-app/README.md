# React 前端模板

基于[umijs](https://umijs.org/)搭建，请先熟悉umijs文档。

## 更新
1.新增登录跳转及token储存本地功能

## 说明
1. 同时支持.js 和.ts 文件写法
2. 路由不支持 users/:id?写法（?选传参数），[说明](https://umijs.org/docs/guides/routes#path)
3. demo 里的 Model、initialState、access，如果没用到前往/config/config.js 关闭

## 组件命名
```
pages/Account/index.js
pages/Account/index.css
```

### 已安装包

```shell
classnames # 方便动态class
js-cookie
axios
moment
prop-types # 组件参数校验 (ts写法可以不用)

```

### 可选

```
react-reveal # 动效插件
```

其他[高质量 React 组件库](https://ant.design/docs/react/recommendation-cn)

# Development

```shell
npm install # 安装依赖
npm dev:dev # 开发 dev 环境
npm dev:prod # 开发 prod 环境
npm dev:test # 开发 test 环境

npm build:dev # 打包 dev 环境
npm build:prod # 打包 prod 环境
npm build:test # 打包 test 环境
```

# 目录结构

```shel
├── dist # 打包输出文件
├── mock #本地的模拟数据服务
│   └── app.js
│   ├── config
│   │   ├── plugins # 插件
│   │   ├── routes # 路由
│   │   ├── config.js # umi配置
│   │   └── config.app.js  # 项目配置
├── src
│   ├── app.js
│   ├── assets  #  静态资源
│   ├── components # 公用组件
│   ├── layouts
│   │   ├── index.js
│   ├── models
│   │   ├── global.js # 全局状态管理
│   ├── pages  # 页面文件
│   │   ├── ***.less
│   │   └── ***.js
│   ├── utils # 工具目录
│   │   ├── comment.js # 公共方法
│   │   ├── cookie.js
│   │   ├── regx.js # 正则相关
│   │   ├── index.js # 入口
│   │   └── request.js # http请求方法
│   ├── services # api接口
│   │   └── xxx.js
│   ├── access.js # 权限
│   ├── global.less # 全局样式
│   ├── favicon.(ico|gif|png|jpg|jpeg|svg|avif|webp)
│   └── loading.js # 组件分包加载loading
├── .env               # 环境变量
├── .eslintrc.js       # eslint的工具的配置文件
├── .gitignore         # 忽略文件配置，不想提交到git仓库的文件可以在这里面配置
├── .stylelintignore   # 配置忽略格式化的文件
├── .stylelintrc.js    # css代码的语法检查
├── package.json       # 包含插件和插件集
├── tsconfig.json      # ts的配置文件
└── typings.d.ts       # 全局类型声明
```
