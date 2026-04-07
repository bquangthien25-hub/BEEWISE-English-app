import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';

class AdminChatDetailPage extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminChatDetailPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminChatDetailPage> createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance.collection('support_chats').doc(widget.userId).set(
            {'unreadForAdmin': 0},
            SetOptions(merge: true),
          );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    
    // Lưu tin nhắn vào Firestore dưới quyền admin (isUser: false)
    final msgData = {
      'text': text,
      'isUser': false, // Admin gửi
      'timestamp': FieldValue.serverTimestamp(),
    };

    final batch = FirebaseFirestore.instance.batch();
    
    final messagesRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.userId)
        .collection('messages')
        .doc();
        
    final chatDocRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.userId);

    batch.set(messagesRef, msgData);
    batch.set(chatDocRef, {
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': widget.userName,
      'unreadForUser': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final viTextStyle = GoogleFonts.beVietnamPro(fontSize: 15, height: 1.35);

    return Scaffold(
      appBar: AppBar(
        title: Text('Đang hỗ trợ: ${widget.userName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(widget.userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Lỗi tải đoạn chat'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Cuộn xuống dòng cuối mỗi lần có tin nhắn mới
                if (docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                }

                if (docs.isEmpty) {
                  return const Center(child: Text('Lịch sử trống.'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isUser = data['isUser'] == true;
                    // Đối với Admin, màn hình sẽ hiển thị ngược lại: 
                    // isUser = true (Khách hàng) -> Bên trái
                    // isUser = false (Admin) -> Bên phải

                    final align = isUser ? Alignment.centerLeft : Alignment.centerRight;
                    final bg = isUser
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : AppColors.primary;
                    final textCol = isUser ? Theme.of(context).colorScheme.onSurface : Colors.white;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Align(
                        alignment: align,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 4 : 16),
                                bottomRight: Radius.circular(isUser ? 16 : 4),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Text(
                                data['text'] ?? '',
                                style: GoogleFonts.beVietnamPro(fontSize: 15, height: 1.35, color: textCol),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: viTextStyle,
                      maxLines: 1,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                      decoration: InputDecoration(
                        hintText: "Nhập phản hồi...",
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
