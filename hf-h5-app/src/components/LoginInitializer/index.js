import React, { useEffect, useState } from "react";
import LoginAccountDev from "@/pages/ModalPages/loginAccount_dev";

const LoginInitializer = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    const initializeLogin = async () => {
      const loginInfoString = localStorage.getItem("loginInfo");
      if (!window.flutter_inappwebview && !loginInfoString) {
        // mock登录
        // loginInfo = (await getUserInfo())?.data;
        setIsModalOpen(true);
      }
    };
    initializeLogin();
  }, []);

  return <LoginAccountDev isOpen={isModalOpen} />; // This component doesn't render anything visible
};

export default LoginInitializer;
