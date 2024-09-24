import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';

class MeMessage extends StatefulWidget {
  @override
  _MeMessageState createState() => _MeMessageState();
}

class _MeMessageState extends State<MeMessage> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    fetchMessages();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchMessages();
    });
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://mesme.in/admin/api/messages/get.php?userId=${_user!.uid}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages =
              data.map((messageJson) => Message.fromJson(messageJson)).toList();
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      // const   print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('https://mesme.in/admin/api/messages/create.php'),
        body: {
          'userId': _user!.uid,
          'message': message,
          'isReply': 'false',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data['message']);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _addMessage(String message) {
    setState(() {
      _messages.insert(
        0,
        Message(
          userId: _user!.uid,
          message: message,
          createdAt: DateTime.now(),
          isReply: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Chat Support',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (_messages.isNotEmpty) _buildDateHeader(_messages[0].createdAt),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                final bool isFirstMessageOfDay = index == 0 ||
                    _messages[index - 1].createdAt.day != message.createdAt.day;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFirstMessageOfDay)
                      _buildDateHeader(message.createdAt),
                    Container(
                      alignment: !message.isReply
                          ? AlignmentDirectional.centerStart
                          : AlignmentDirectional.centerEnd,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: !message.isReply ? Colors.orange : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.message,
                              style: TextStyle(
                                  color: !message.isReply
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message...',
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                      onSubmitted: (String text) {
                        _addMessage(text);
                        sendMessage(text);
                        _controller.clear();
                      },
                    ),
                  ),
                  IconButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.orange),
                    ),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _addMessage(_controller.text);
                        sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: const Text(
          'Today',
          style: TextStyle(color: Colors.black),
        ),
      );
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: const Text(
          'Yesterday',
          style: TextStyle(color: Colors.black),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(color: Colors.black),
        ),
      );
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute}';
  }
}

class Message {
  final String userId;
  final String message;
  final DateTime createdAt;
  final bool isReply;

  Message({
    required this.userId,
    required this.message,
    required this.createdAt,
    required this.isReply,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      userId: json['userId'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isReply: json['isReply'] == "1", // Convert "1" to true, "0" to false
    );
  }
}
