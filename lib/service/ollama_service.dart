import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  Future getResponse(String prompt) async {
 final client = http.Client();
  final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': '',
    'HTTP-Referer': '<YOUR_SITE_URL>', // Optional
    'X-Title': '<YOUR_SITE_NAME>', // Optional
  };

  final body = jsonEncode({
    'model': 'deepseek/deepseek-r1-distill-llama-70b:free',
    'messages': [
      {'role': 'user', 'content': prompt},
    ],
  });

  try {
    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meaningOfLife = data['choices'][0]['message']['content'];
     
      return meaningOfLife;
      // You can now use the meaningOfLife variable in your Flutter UI
    } else {
  
      // Handle the error appropriately in your Flutter UI
    }
  } catch (e) {

    // Handle the exception appropriately in your Flutter UI
  } finally {
    client.close();
  }
}

}
