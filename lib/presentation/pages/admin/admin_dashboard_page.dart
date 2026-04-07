import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/support_chat_unread.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khu vực Quản Trị'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('support_chats').snapshots(),
            builder: (context, snapshot) {
              var totalUnread = 0;
              for (final d in snapshot.data?.docs ?? []) {
                totalUnread += supportUnreadCount(
                  d.data() as Map<String, dynamic>?,
                  'unreadForAdmin',
                );
              }
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.support_agent_rounded, color: Colors.white),
                  ),
                  title: const Text('Hỗ trợ Khách hàng (Chat)'),
                  subtitle: const Text('Xem danh sách người cần hỗ trợ và trả lời'),
                  trailing: Badge(
                    isLabelVisible: totalUnread > 0,
                    label: Text(totalUnread > 99 ? '99+' : '$totalUnread'),
                    child: const Icon(Icons.chevron_right_rounded),
                  ),
                  onTap: () {
                    context.push('/admin/chats');
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
