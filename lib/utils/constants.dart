class AppConstants {
  // Collections
  static const String todosCollection = 'todos';
  static const String usersCollection = 'users';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String todoListRoute = '/todos';
  static const String todoDetailRoute = '/todo/detail';
  static const String todoFormRoute = '/todo/form';
  static const String profileRoute = '/profile';

  // Error messages
  static const String errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String errorNetwork = 'Lỗi kết nối. Vui lòng kiểm tra internet.';
  static const String errorAuth = 'Lỗi xác thực. Vui lòng đăng nhập lại.';
  static const String errorNotFound = 'Không tìm thấy dữ liệu.';
  static const String errorPermission = 'Bạn không có quyền thực hiện thao tác này.';

  // Success messages
  static const String successCreate = 'Tạo thành công!';
  static const String successUpdate = 'Cập nhật thành công!';
  static const String successDelete = 'Xóa thành công!';
  static const String successLogin = 'Đăng nhập thành công!';
  static const String successRegister = 'Đăng ký thành công!';
  static const String successPasswordChange = 'Đổi mật khẩu thành công!';
}

