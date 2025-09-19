const userInfo = { "clientIdentity": "c9e4e6ab-cc6a-4f98-8344-d8c81474c086", "platform": "APP", "userId": "1", "tenantId": null, "username": "humi_admin", "realName": "超级管理员", "phoneNo": "17782054338", "email": null, "userType": "PLATFORM_ADMIN", "accountNonExpired": true, "accountNonLocked": true, "credentialsNonExpired": true, "enabled": true, "tokenId": "104abf04-9b2d-43c8-8649-4c5e3d1b5c6a", "company": { "id": "1", "name": "宗申机车", "companyType": 4, "cardNo": null, "licenseImg": null, "licenseType": null, "industryCode": "I", "industryName": null, "registerArea": "500000,500107", "registerAreaName": null, "registerAddress": null, "website": null, "introduce": null, "liaisonId": null, "liaison": null, "liaisonPhone": null, "liaisonEmail": null, "legalPerson": null, "legalCradType": 1, "legalCardNo": null, "legalCardImg": null, "authStatus": 1, "examineStatus": 1, "identifyPrefix": null }, "resources": null, "authorities": [], "orgInfo": null, "enterpriseId": null, "lineName": "装配1线", "lineCode": null, "lineId": "1798174175539040258", "lineOrgPath": null, "processId": null, "processCode": null, "processName": null, "opMode": null, "stationId": "1", "stationCode": "子岗位2", "stationName": "子岗位2", "equipmentCode": "", "equipmentId": "", "equipmentName": "", "isSubStation": true, "stationChildren": [] };

export default {
  "GET /api/loginInfo": (req, res) => {
    res.json({
      success: true,
      data: userInfo,
      errorCode: 0,
    });
  },
  "GET /api/listVins": (req, res) => {
    res.json({
      success: true,
      data: [
        { vin: 'CA5001-ⅡI24G002', status: 'active' },
        { vin: 'CA5001-ⅡI24G003', status: 'inactive' },
      ],
      errorCode: 0,
    });
  },
  "GET /api/tighteningSteps": (req, res) => {
    res.json({
      success: true,
      data: {
        bg: "",
        sortNo: 0,
        status: "",
        finishStatus: "",
        point: [
          {
            content: "前轮螺栓",
            standard: "拧紧力矩 25N.m",
            torque: 25.0,
            angle: 90,
            x: 10.0,
            y: 20.0,
            status: "completed",
            confirmStatus: "confirmed",
            id: "point001",
            stepLogId: "log001",
            type: "torque",
            sortNo: 1,
            value1: "OK",
            value2: "",
            createBy: "userA",
            createTime: "2023-01-01 10:00:00",
            createName: "操作员A",
            value3: "",
            resultProcess: "自动",
            stationId: "station001",
            stepId: "step001",
            vin: "CA5001-ⅡI24G002",
            resultStatus: "PASS"
          },
          {
            content: "后视镜安装",
            standard: "无松动",
            torque: 0.0,
            angle: 0,
            x: 30.0,
            y: 40.0,
            status: "pending",
            confirmStatus: "unconfirmed",
            id: "point002",
            stepLogId: "log002",
            type: "visual",
            sortNo: 2,
            value1: "",
            value2: "",
            createBy: "userB",
            createTime: "2023-01-01 10:05:00",
            createName: "操作员B",
            value3: "",
            resultProcess: "手动",
            stationId: "station001",
            stepId: "step001",
            vin: "CA5001-ⅡI24G002",
            resultStatus: ""
          },
          {
            content: "发动机油位检查",
            standard: "油位正常",
            torque: 0.0,
            angle: 0,
            x: 50.0,
            y: 60.0,
            status: "in_progress",
            confirmStatus: "unconfirmed",
            id: "point003",
            stepLogId: "log003",
            type: "check",
            sortNo: 3,
            value1: "",
            value2: "",
            createBy: "userC",
            createTime: "2023-01-01 10:10:00",
            createName: "操作员C",
            value3: "",
            resultProcess: "手动",
            stationId: "station001",
            stepId: "step001",
            vin: "CA5001-ⅡI24G002",
            resultStatus: ""
          }
        ]
      },
      errorCode: 0,
    });
  },
};
