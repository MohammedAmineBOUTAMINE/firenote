// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLogin ? 'LOGIN' : 'SIGNUP',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: _validateEmail,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: _validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showPasswordResetDialog,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign Up'
                        : 'Already have an account? Log In',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_isLogin ? 'LOGIN' : 'SIGNUP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    // Optional: Add more complex password validation
    if (!_isLogin) {
      // Signup-specific password validation
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
        return 'Password must contain at least one uppercase letter';
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
        return 'Password must contain at least one lowercase letter';
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
        return 'Password must contain at least one number';
      }
    }
    return null;
  }

  Future<void> _authenticate() async {
    // Check form validation
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        await _signIn(email, password);
      } else {
        await _signUp(email, password);
      }

      // Navigate to NotesScreen on successful authentication
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NotesScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred');
    }
  }

  Future<void> _signIn(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> _signUp(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: _validateEmail,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate email before sending reset
              if (_validateEmail(_emailController.text) == null) {
                _sendPasswordResetEmail(_emailController.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSuccessDialog('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAuthException(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found with this email.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak.';
        break;
      case 'email-already-in-use':
        errorMessage = 'An account already exists with this email.';
        break;
      case 'network-request-failed':
        errorMessage = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage = 'Authentication failed. Please try again.';
    }

    _showErrorDialog(errorMessage);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}



class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> _notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info dialog
            },
          ),
        ],
      ),
      body: _notes.isEmpty
          ? const EmptyStateWidget()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          return NoteCard(note: _notes[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditor(context);
        },
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditor(BuildContext context, {Note? existingNote}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: existingNote,
          onSave: (title, content) {
            setState(() {
              if (existingNote == null) {
                _notes.add(
                  Note(
                    id: DateTime.now().toString(),
                    title: title,
                    content: content,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
              } else {
                existingNote.title = title;
                existingNote.content = content;
                existingNote.updatedAt = DateTime.now();
              }
            });
          },
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty_notes.png', // Add this image to your assets
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'Create your first note!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final Function(String title, String content) onSave;

  const NoteEditorScreen({
    Key? key,
    this.note,
    required this.onSave,
  }) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasUnsavedChanges) {
              _showSaveDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_titleController.text, _contentController.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              onChanged: (value) => _hasUnsavedChanges = true,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Type something...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) => _hasUnsavedChanges = true,
            ),
          ),
          const NoteToolbar(),
        ],
      ),
    );
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save changes?'),
        content: const Text('Do you want to save your changes?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSave(_titleController.text, _contentController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          note.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(
                note: note,
                onSave: (title, content) {
                  note.title = title;
                  note.content = content;
                  note.updatedAt = DateTime.now();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}