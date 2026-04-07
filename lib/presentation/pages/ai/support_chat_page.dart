import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../data/user_profile_store.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    final user = sl<UserProfileStore>().current;
    if (user != null) {
      _userId = user.id;
      _userName = user.name;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = _userId;
      if (id == null) return;
      FirebaseFirestore.instance.collection('support_chats').doc(id).set(
            {'unreadForUser': 0},
            SetOptions(merge: true),
          );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
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
    if (text.isEmpty || _userId == null) return;
    
    _textController.clear();
    
    // Lưu tin nhắn vào Firestore (isUser: true)
    final msgData = {
      'text': text,
      'isUser': true, // User gửi
      'timestamp': FieldValue.serverTimestamp(),
    };

    final batch = FirebaseFirestore.instance.batch();
    
    final messagesRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_userId)
        .collection('messages')
        .doc();
        
    final chatDocRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_userId);

    batch.set(messagesRef, msgData);
    batch.set(chatDocRef, {
      'lastMessage': text,
      'timestamp': FieldValue.serverTimestamp(),
      'userName': _userName ?? 'BeeWise User',
      'unreadForAdmin': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();

    _scrollToBottom();
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.supportChatScreenTitle)),
        body: const Center(child: Text('Vui lòng đăng nhập để sử dụng tính năng này.')),
      );
    }
    
    final tt = Theme.of(context).textTheme;
    final beeMuted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);
    final viTextStyle = GoogleFonts.beVietnamPro(fontSize: 15, height: 1.35);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.supportChatScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.support_agent_rounded, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.supportChatAgentLabel,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.supportChatStatusHint,
                        style: tt.bodySmall?.copyWith(color: beeMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(_userId)
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
                
                // Cuộn xuống dòng cuối
                if (docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppStrings.supportChatEmptyHint,
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(color: beeMuted),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isUser = data['isUser'] == true;
                    return _MessageBubble(text: data['text'] ?? '', isUser: isUser);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _inputFocusNode,
                      style: viTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      smartDashesType: SmartDashesType.disabled,
                      smartQuotesType: SmartQuotesType.disabled,
                      spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: AppStrings.supportChatInputHint,
                        hintStyle: viTextStyle.copyWith(color: beeMuted),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _send,
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.send_rounded, color: AppColors.onPrimaryStrong, size: 22),
                      ),
                    ),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final viStyle = GoogleFonts.beVietnamPro(
      fontSize: 15,
      height: 1.35,
      color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
    );
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isUser
        ? AppColors.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

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
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                text,
                style: viStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
