import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  
 Future<String> getResponse(String prompt) async {
  final url = Uri.parse('http://localhost:11434/api/generate -d');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'model': 'mistral', // Using the available model
      'prompt': prompt,
     
    }),
  );

  print(response.body);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    // Extract the AI's response text
    return json['choices'][0]['text'];
  } else {
    throw Exception('Failed to get response from Ollama');
  }
}


}
