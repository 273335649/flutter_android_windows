import { history } from "umi";

const Login = () => {
  return (
    <div className="container">
      <h1>Login Page</h1>
      <p>没有导航</p>
      <a onClick={() => history.back()}>返回</a>
    </div>
  );
};

Login.propTypes = {};

export default Login;
