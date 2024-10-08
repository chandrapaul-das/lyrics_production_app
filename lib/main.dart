import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF222831), // Background color
      ),
      home: LyricsGeneratorPage(),
    );
  }
}

class LyricsGeneratorPage extends StatefulWidget {
  @override
  _LyricsGeneratorPageState createState() => _LyricsGeneratorPageState();
}

class _LyricsGeneratorPageState extends State<LyricsGeneratorPage> {
  final TextEditingController langController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String? lyrics1;
  String? lyrics2;
  bool isLoading = false;

  Future<void> generateLyrics() async {
    // Check for empty inputs before making the API call
    if (langController.text.isEmpty || genreController.text.isEmpty) {
      _showMessageDialog();
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://lyrics-production-app.onrender.com/generate-lyrics/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'lang': langController.text,
        'genre': genreController.text,
        'desc': descController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        lyrics1 = data['lyrics_1'];
        lyrics2 = data['lyrics_2'];
      });
    } else if (response.statusCode == 500) {
      // Show message if the API returns a 500 internal server error
      _showMessageDialog();
    } else {
      setState(() {
        lyrics1 = 'Error: ${response.statusCode}';
        lyrics2 = 'Error generating lyrics';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to show the message dialog
  void _showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Input Error'),
          content: Text(
            'Possible reasons for failure:\n\n'
            '• The given language or genre might not be appropriate\n'
            '• Language or Genre is not provided',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 80, // Adjust this height to suit your logo size
          child: Image.asset(
            'assets/logo.png', // Replace with your image path
            fit: BoxFit.contain, // Ensures the logo is fully visible
          ),
        ),
        centerTitle: true, // Center the image in the AppBar
        backgroundColor: Color(0xFF222831), // Same background color as the app
        elevation: 0, // Remove shadow below the app bar
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover, // Background image covers the entire screen
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Language and Genre textboxes side by side
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTextField(langController, 'Language', Color(0xFF15F5BA), 0.7),
                  SizedBox(width: 16),
                  _buildTextField(genreController, 'Genre', Color(0xFF15F5BA), 0.7),
                ],
              ),
              SizedBox(height: 20),
              // Description textbox
              _buildDescriptionField(),
              SizedBox(height: 20),
              // Generate Lyrics button
              _buildGenerateButton(),
              SizedBox(height: 20),
              // Check if lyrics are generated before showing the lyrics boxes
              if (lyrics1 != null && lyrics2 != null) ...[
                // Generated Lyrics text boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLyricsBox('Version-1', lyrics1),
                    SizedBox(width: 16),
                    _buildLyricsBox('Version-2', lyrics2),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Create a rounded TextField with specific color and transparency
  Widget _buildTextField(TextEditingController controller, String labelText, Color labelColor, double transparency) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF31363F).withOpacity(transparency), // Box transparency
          borderRadius: BorderRadius.circular(15.0), // Less rounded corners
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: labelColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0), // Less rounded corners
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increased vertical padding
          ),
          style: TextStyle(color: Colors.white, height: 2.0), // Solid white text, increased height
        ),
      ),
    );
  }

  // Create a rounded TextField for description
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF31363F).withOpacity(0.7), // Box transparency
        borderRadius: BorderRadius.circular(15.0), // Less rounded corners
      ),
      child: TextField(
        controller: descController,
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(color: Color(0xFF15F5BA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0), // Less rounded corners
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increased vertical padding
        ),
        maxLines: 2,
        style: TextStyle(color: Colors.white, height: 2.0), // Solid white text, increased height
      ),
    );
  }

  // Create a button to generate lyrics
  Widget _buildGenerateButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : generateLyrics,
      child: isLoading
          ? CircularProgressIndicator(color: Color.fromARGB(255, 28, 167, 135)) // Show loader
          : Text('Generate Lyrics', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF15F5BA).withOpacity(0.3), // Button transparency
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Less rounded corners
        ),
        padding: EdgeInsets.symmetric(vertical: 20), // Increased padding for height
      ),
    );
  }

  // Create the lyrics box
  Widget _buildLyricsBox(String title, String? lyrics) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 9, 60, 55).withOpacity(0.8), // Box color and transparency
          borderRadius: BorderRadius.circular(15.0), // Less rounded corners
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8.0),
            Text(lyrics ?? 'No lyrics generated', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
