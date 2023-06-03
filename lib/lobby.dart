import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

class Lobby {
  final String lobbyName;
  final List<String> users;

  Lobby({
    required this.lobbyName,
    required this.users,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      lobbyName: json['lobbyName'] ?? '',
      users: List<String>.from(json['users']?.map((user) => user['userName']) ?? []),
    );
  }
}

class LobbyPage extends StatelessWidget {
  final String lobbyName;
  final TextEditingController usernameController = TextEditingController();

  LobbyPage({required this.lobbyName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby: $lobbyName'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                joinLobby(context);
              },
              child: Text('Lobby beitreten'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> joinLobby(BuildContext context) async {
    final url = Uri.parse('http://195.37.49.59:8080/ar-23-backend/api/battleship/enter');
    final headers = {'Content-Type': 'application/json'};
    final username = usernameController.text.trim();
    final appId = Uuid().v4(); // Génère un appId unique à l'aide de l'UUID

    if (username.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Fehler'),
          content: Text('Geben Sie bitter ein Username ein'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final body = jsonEncode({
      'lobbyName': lobbyName,
      'appId': appId,
      'username': username,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final socketURL = responseData['socketURL'];

      final channel = IOWebSocketChannel.connect(socketURL);
      channel.stream.listen((message) {
        print('Eingehende Nachricht: $message');
      });

      print('Erfolgreich der Lobby $lobbyName beigetreten.');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erfolgreich beigetreten'),
          content: Text('Sie sind der Lobby $lobbyName beigetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('Fehler beim Beitreten der Lobby $lobbyName. Statuscode: ${response.statusCode}');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Fehler beim Beitreten'),
          content: Text('Beim Beitreten zur Lobby $lobbyName ist ein Fehler aufgetreten.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
