class API {
  static const hostConnect = "http://192.168.189.1/api_new_members"; // ipconfig로 가져온 서버 IP
  static const hostConnectUser = "$hostConnect/user";
  
  // 사용자 관련 API
  static const signup = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";
  static const validateEmail = "$hostConnectUser/validate_email.php";
  static const addEmployee = "$hostConnectUser/add_employee.php";

  static const getProducts = "$hostConnectUser/getProducts.php";
  static const addOrderWithReceiver = "$hostConnectUser/addOrderWithReceiver.php";
  static const updateOrder = "$hostConnectUser/updateOrder.php";
  static const deleteOrder = "$hostConnectUser/deleteOrder.php";
  static const getOrders = "$hostConnectUser/getOrders.php";
  static const validateZipCode = "$hostConnectUser/validateZipCode.php";

}
