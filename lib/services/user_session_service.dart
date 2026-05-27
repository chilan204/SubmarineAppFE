import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_session_record.dart';
import '../config/api_config.dart';

class UserSessionService {
  Future<List<UserSessionRecord>> fetchMySessions(String token) async {
    final uri = Uri.parse(ApiConfig.mySessions);
    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        
        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> list = body['data'];
          return list.map((item) => UserSessionRecord.fromJson(item)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load user sessions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching user sessions: $e');
    }
  }
}
