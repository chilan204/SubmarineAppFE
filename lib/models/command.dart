// Command data model — mirrors VoiceControlScreen.tsx Command interface
class Command {
  final String id;
  final String text;
  final DateTime timestamp;
  final CommandStatus status;
  final String response;

  const Command({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.status,
    required this.response,
  });
}

enum CommandStatus { success, warning, error }
