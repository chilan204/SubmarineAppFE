import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/voice_command_response.dart';

class VoiceCommandService {
  Future<VoiceCommandResult> sendVoiceCommand({
    required List<int> audioBytes,
    required String token,
    String? language,
    String filename = 'command.wav',
  }) async {
    try {
      final uri = Uri.parse(ApiConfig.voiceCommand);
      final request = http.MultipartRequest('POST', uri);

      // Auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Attach file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: filename,
        ),
      );

      if (language != null) {
        request.fields['language'] = language;
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      final Map<String, dynamic> body =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final message = body['message'] as String?;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'];
        if (data is! Map<String, dynamic>) {
          return VoiceCommandResult(
            success: false,
            message: message ?? 'Invalid response data',
          );
        }
        return VoiceCommandResult(
          success: true,
          data: VoiceCommandResponse.fromJson(data),
          message: message,
        );
      }

      // Handle structured error responses (e.g. 403 Forbidden with VoiceCommandResponse info)
      if (body['data'] != null && body['data'] is Map<String, dynamic>) {
        return VoiceCommandResult(
          success: false,
          data: VoiceCommandResponse.fromJson(body['data'] as Map<String, dynamic>),
          message: message,
        );
      }

      return VoiceCommandResult(
        success: false,
        message: message ?? 'Request failed: ${response.statusCode}',
      );
    } catch (e) {
      return VoiceCommandResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
