import 'package:flutter/material.dart';

import '../../../core/models/contact.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/app_state_scope.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.thread, this.initialFocusRole});

  final ChatThread thread;
  final ContactRole? initialFocusRole;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final thread = appState.chatThreadById(widget.thread.id) ?? widget.thread;
    final dispatcherContact = Contact(
      id: 'dispatcher-${appState.dispatcherProfile.email}',
      name: appState.dispatcherProfile.name,
      role: ContactRole.dispatcher,
      maskedPhone: appState.dispatcherProfile.phone,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(thread.subject),
        subtitle: Text('Order ${thread.assignmentId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: thread.messages.length,
              itemBuilder: (context, index) {
                final message = thread.messages.reversed.elementAt(index);
                final isDispatcher = message.sender.role == ContactRole.dispatcher;
                return Align(
                  alignment: isDispatcher ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDispatcher
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isDispatcher ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(message.body),
                        const SizedBox(height: 4),
                        Text(
                          TimeOfDay.fromDateTime(message.sentAt).format(context),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Send an update…',
                      ),
                      onSubmitted: (_) => _sendMessage(dispatcherContact),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => _sendMessage(dispatcherContact),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(Contact dispatcherContact) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final appState = AppStateScope.of(context);
    final message = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sender: dispatcherContact,
      body: text,
      sentAt: DateTime.now(),
      isFromDispatcher: true,
    );
    appState.appendMessage(widget.thread.id, message);
    _messageController.clear();
  }
}
