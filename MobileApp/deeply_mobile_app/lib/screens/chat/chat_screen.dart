import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/couple_provider.dart';
import '../../data/models/message_model.dart';

// ─── Item type for the flat list (message | date-divider) ─────────────────────
class _ChatItem {
  final bool isDivider;
  final String? dividerLabel;
  final MessageModel? message;

  const _ChatItem.divider(String label)
      : isDivider = true,
        dividerLabel = label,
        message = null;

  const _ChatItem.msg(MessageModel m)
      : isDivider = false,
        dividerLabel = null,
        message = m;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    if (!mounted) return;
    // Ensure user profile is loaded
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) await auth.fetchProfile();

    // Ensure partner name is loaded
    if (mounted) {
      final couple = context.read<CoupleProvider>();
      if (couple.partnerName == null && auth.userId != null) {
        await couple.fetchPartnerProfile(auth.userId!);
      }
    }

    // Fetch chat history
    if (mounted) {
      await context.read<ChatProvider>().fetchHistory();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    final ok = await context.read<ChatProvider>().sendMessage(text: text);
    if (ok) _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(String sentAtUtc) {
    try {
      final dt = DateTime.parse(sentAtUtc).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    if (msgDay == today) return 'Сегодня';
    if (msgDay == yesterday) return 'Вчера';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }

  /// Builds a flat list interleaving date-dividers and message items.
  List<_ChatItem> _buildItems(List<MessageModel> messages) {
    final items = <_ChatItem>[];
    String? lastDateKey;

    for (final msg in messages) {
      try {
        final dt = DateTime.parse(msg.sentAtUtc).toLocal();
        final key = '${dt.year}-${dt.month}-${dt.day}';
        if (key != lastDateKey) {
          items.add(_ChatItem.divider(_formatDateLabel(dt)));
          lastDateKey = key;
        }
      } catch (_) {}
      items.add(_ChatItem.msg(msg));
    }
    return items;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final myUserId = context.watch<AuthProvider>().userId;
    final coupleProvider = context.watch<CoupleProvider>();
    final partnerName = coupleProvider.partnerName ?? 'Партнёр';
    final partnerInitial =
        partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'П';

    final items = _buildItems(chat.messages);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: _buildAppBar(partnerName, partnerInitial),
      body: Column(
        children: [
          // Loading bar while fetching history
          if (chat.isLoading && chat.messages.isEmpty)
            const LinearProgressIndicator(
              backgroundColor: AppColors.bgCard,
              color: AppColors.primary,
              minHeight: 2,
            ),
          Expanded(
            child: chat.messages.isEmpty && !chat.isLoading
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item.isDivider) {
                        return _DateDivider(label: item.dividerLabel!);
                      }
                      final msg = item.message!;
                      final isMe = msg.senderUserId == myUserId;
                      return _buildMessage(msg, isMe);
                    },
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String partnerName, String partnerInitial) {
    return AppBar(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Text(
                partnerInitial,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                partnerName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const Text(
                'Онлайн',
                style: TextStyle(color: AppColors.accentGreen, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(
            'Начните разговор',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Photo placeholder
            if (msg.photoUrl != null)
              Container(
                width: 180,
                height: 140,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(Icons.image,
                    color: AppColors.textHint, size: 40),
              ),
            // Text bubble
            if (msg.text != null && msg.text!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.bgCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                ),
                child: Text(
                  msg.text!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ),
            const SizedBox(height: 2),
            // Time + read receipt
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.sentAtUtc),
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 11),
                ),
                if (isMe) ...[
                  const SizedBox(width: 3),
                  Text(
                    msg.isRead ? '✓✓' : '✓',
                    style: TextStyle(
                      color: msg.isRead
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: TextField(
                controller: _messageController,
                style:
                    const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Написать...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date Divider ─────────────────────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
              child:
                  Divider(color: Colors.white.withValues(alpha: 0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 12)),
          ),
          Expanded(
              child:
                  Divider(color: Colors.white.withValues(alpha: 0.1))),
        ],
      ),
    );
  }
}
