/**
 * 正则验证
 */
const regex = {
  isTel(num) {
    const reg = /^((1[0-9])+\d{9})$/;
    return reg.test(num);
  },
  isEmail(str) {
    const reg = /\S+@\S+\.\S+/;
    return reg.test(str);
  },
  // 判断是否为ip
  isIP(str) {
    const regexExp =
      /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/gi;
    return regexExp.test(str);
  },
};

export default regex;
