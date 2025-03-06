import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ollama_alexa/service/ollama_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _ollamaService = OllamaService();
  bool loading = false;
  final ScrollController _scrollController = ScrollController();

  
void _scrollToBottom() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    _scrollController
    .addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }});
}

  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollToBottom();
  }

  // Load messages from SharedPreferences
  void _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> messageList = prefs.getStringList('messages') ?? [];

    setState(() {
      _messages.clear();
      for (var message in messageList) {
        final messageParts = message.split('|');
        if (messageParts.length == 2) {
          _messages.add({'text': messageParts[0], 'sender': messageParts[1]});
        }
      }
    });
  }

  // Save messages to SharedPreferences
  void _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> messageList = _messages.map((message) {
      return '${message['text']}|${message['sender']}';
    }).toList();
    prefs.setStringList('messages', messageList);
  }

  // Send the prompt and get the response
  void _sendPrompt() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      // Add the user's message to the list
      _messages.add({'text': userMessage, 'sender': 'User'});
      loading = true;
    });

    _controller.clear();

    try {

      final result = await _ollamaService.getResponse(userMessage);
      print(  result);
      setState(() {
        // Add the AI's response to the list
        loading = false;
        _messages.add({'text': result, 'sender': 'AI'});
      });
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error: $e', 'sender': 'AI'});
        loading = false;
      });
    }

    // Save the updated messages list
    _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sam Bot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isUser = message['sender'] == 'User';
              return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[100] : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message['text'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.black : Colors.black87,
              ),
            ),
          ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter your message',
              border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
            ),
            IconButton(
          icon: Icon(Icons.mic),
          onPressed: _startListening,
            ),
            loading?Center(child: CircularProgressIndicator()):IconButton(
          icon: Icon(Icons.send),
          onPressed: _sendPrompt,
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    final speech = SpeechToText();
    bool available = await speech.initialize();
    if (available) {
      speech.listen(onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
      });
    } else {
      // Handle the error
      setState(() {
        _messages.add({'text': 'Speech recognition not available', 'sender': 'System'});
      });
    }
  }

  void _speak(String text) async {
    // Implement text to voice functionality here
  }
}
