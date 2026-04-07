abstract final class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên';
    }
    if (value.trim().length < 2) {
      return 'Tên tối thiểu 2 ký tự';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final email = value.trim();
    final ok = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!ok) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return 'Mật khẩu tối thiểu $minLength ký tự';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }
    if (value != original) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }
}
