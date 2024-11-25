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
  static const updateParcelPersonnel = "$hostConnectUser/updateParcelPersonnel.php";
  static const updateCurrentState = "$hostConnectUser/updateCurrentState.php";
  static const getOrderDetails = "$hostConnectUser/getOrderDetails.php";

  static const getAvailableParcels = "$hostConnectUser/getAvailableParcels.php";
  static const submitInquiry = "$hostConnectUser/submitInquiry.php";
  static const getInquiryDetails = "$hostConnectUser/getInquiryDetails.php";
  static const deleteInquiry = "$hostConnectUser/deleteInquiry.php";
  static const changeInquiry = "$hostConnectUser/changeInquiry.php";

  static const resolveInquiry = "$hostConnectUser/resolveInquiry.php";
  static const getEmployeeInquiries = "$hostConnectUser/getEmployeeInquiries.php";
  static const updateInquiryComment = "$hostConnectUser/updateInquiryComment.php";

  static const getInquiries = "$hostConnectUser/getInquiries.php";

  static const getIssues = "$hostConnectUser/getIssues.php";
  static const submitReport = "$hostConnectUser/submitReport.php";
  static const getEmployeeId = "$hostConnectUser/getEmployeeId.php";

  static const getReportsByEmployee = "$hostConnectUser/get_reports_by_employee.php";
  static const deleteReport = "$hostConnectUser/delete_report.php";

  static const updateProblemState = "$hostConnectUser/updateProblemState.php";
  static const updateReportComment = "$hostConnectUser/updateReportComment.php";
}
