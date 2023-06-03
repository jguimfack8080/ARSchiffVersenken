import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LobbyListScreen extends StatefulWidget {
  @override
  _LobbyListScreenState createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  List<Map<String, dynamic>> lobbies = [];

  @override
  void initState() {
    super.initState();
    fetchLobbies();
  }

  Future<void> fetchLobbies() async {
    try {
      final response = await http.get(Uri.parse('http://195.37.49.59:8080/ar-23-backend/api/battleship/list'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            lobbies = data.map((lobby) => lobby as Map<String, dynamic>).toList();
          });
        } else {
          print('Failed to fetch lobbies. Invalid response data.');
        }
      } else {
        // Handle other status codes if needed
        print('Failed to fetch lobbies. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors
      print('Failed to fetch lobbies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby List'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: lobbies.length,
                itemBuilder: (context, index) {
                  final lobby = lobbies[index];
                  final lobbyName = lobby['lobbyName'] as String;
                  final userList = lobby['users'] as List<dynamic>;

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        lobbyName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Users: ${userList.map((user) => user['userName'] as String).join(', ')}',
                      ),
                      trailing: Icon(Icons.login, color: Colors.blue),
                      onTap: () {
                        // Handle lobby selection
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
