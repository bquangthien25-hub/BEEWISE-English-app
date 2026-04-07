/// Đọc số tin chưa đọc từ document `support_chats/{id}` (mặc định 0 nếu chưa có field).
int supportUnreadCount(Map<String, dynamic>? data, String key) {
  if (data == null) return 0;
  final v = data[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  return 0;
}
