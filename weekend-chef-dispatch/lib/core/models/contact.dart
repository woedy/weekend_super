enum ContactRole { dispatcher, cook, client, support }

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.role,
    this.maskedPhone,
  });

  final String id;
  final String name;
  final ContactRole role;
  final String? maskedPhone;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAt,
    this.isFromDispatcher = false,
  });

  final String id;
  final Contact sender;
  final String body;
  final DateTime sentAt;
  final bool isFromDispatcher;
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.assignmentId,
    required this.subject,
    required this.participants,
    required this.messages,
  });

  final String id;
  final String assignmentId;
  final String subject;
  final List<Contact> participants;
  final List<ChatMessage> messages;

  ChatThread copyWith({List<ChatMessage>? messages}) {
    return ChatThread(
      id: id,
      assignmentId: assignmentId,
      subject: subject,
      participants: participants,
      messages: messages ?? this.messages,
    );
  }
}
