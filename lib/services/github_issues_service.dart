import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for integrating with GitHub Issues API
class GitHubIssuesService {
  String? _accessToken;
  String? _owner; // Repository owner
  String? _repo; // Repository name
  
  GitHubIssuesService({
    String? accessToken,
    String? owner,
    String? repo,
  }) : _accessToken = accessToken,
       _owner = owner,
       _repo = repo;
  
  void configure(String accessToken, String owner, String repo) {
    _accessToken = accessToken;
    _owner = owner;
    _repo = repo;
  }
  
  // Create GitHub issue from task
  Future<Map<String, dynamic>> createIssue({
    required String title,
    required String body,
    List<String>? labels,
    String? assignee,
  }) async {
    if (_accessToken == null || _owner == null || _repo == null) {
      throw Exception('GitHub Issues not configured');
    }
    
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/issues');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'labels': labels,
        if (assignee != null) 'assignee': assignee,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create issue: ${response.statusCode} - ${response.body}');
    }
  }
  
  // Update GitHub issue
  Future<Map<String, dynamic>> updateIssue({
    required int issueNumber,
    String? title,
    String? body,
    String? state, // 'open' or 'closed'
    List<String>? labels,
  }) async {
    if (_accessToken == null || _owner == null || _repo == null) {
      throw Exception('GitHub Issues not configured');
    }
    
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/issues/$issueNumber');
    
    final bodyData = <String, dynamic>{};
    if (title != null) bodyData['title'] = title;
    if (body != null) bodyData['body'] = body;
    if (state != null) bodyData['state'] = state;
    if (labels != null) bodyData['labels'] = labels;
    
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bodyData),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update issue: ${response.statusCode} - ${response.body}');
    }
  }
  
  // Get issue by number
  Future<Map<String, dynamic>> getIssue(int issueNumber) async {
    if (_accessToken == null || _owner == null || _repo == null) {
      throw Exception('GitHub Issues not configured');
    }
    
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/issues/$issueNumber');
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get issue: ${response.statusCode}');
    }
  }
  
  // List issues
  Future<List<Map<String, dynamic>>> listIssues({
    String? state, // 'open', 'closed', 'all'
    String? assignee,
    List<String>? labels,
  }) async {
    if (_accessToken == null || _owner == null || _repo == null) {
      throw Exception('GitHub Issues not configured');
    }
    
    final queryParams = <String, String>{};
    if (state != null) queryParams['state'] = state;
    if (assignee != null) queryParams['assignee'] = assignee;
    if (labels != null && labels.isNotEmpty) {
      queryParams['labels'] = labels.join(',');
    }
    
    final url = Uri.parse('https://api.github.com/repos/$_owner/$_repo/issues')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> issues = jsonDecode(response.body);
      return issues.map((issue) => issue as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to list issues: ${response.statusCode}');
    }
  }
}
