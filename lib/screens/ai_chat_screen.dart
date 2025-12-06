import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/utils/utils.dart';

// --- Configuration (devrait être dans .env ou config sécurisée) ---
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Configuration ---
// Clé récupérée depuis le fichier .env
final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

class AiChatScreen extends ConsumerStatefulWidget {
  static AiChatScreen builder(BuildContext context, GoRouterState state) =>
      const AiChatScreen();

  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<({String role, String message, bool isLoading})> _history = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  void _initModel() {
    // Définition des outils (Tools)
    final tools = [
      Tool(functionDeclarations: [
        FunctionDeclaration(
          'createTask',
          'Creates a new task with a title, optional note, date, and time.',
          Schema(
            SchemaType.object,
            properties: {
              'title': Schema(SchemaType.string,
                  description: 'The title of the task.'),
              'note': Schema(SchemaType.string,
                  description: 'Additional notes for the task.',
                  nullable: true),
              'date': Schema(SchemaType.string,
                  description: 'The date of the task in YYYY-MM-DD format.'),
              'time': Schema(SchemaType.string,
                  description: 'The time of the task in HH:mm format.'),
            },
            requiredProperties: ['title', 'date', 'time'],
          ),
        ),
      ]),
    ];

    _model = GenerativeModel(
      model: 'gemini-pro', // Using basic model for broad compatibility
      apiKey: _apiKey,
      tools: tools,
    );

    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _loading) return;

    setState(() {
      _history.add((role: 'user', message: message, isLoading: false));
      _loading = true;
      _textController.clear();
    });
    _scrollToBottom();

    try {
      var response = await _chat.sendMessage(Content.text(message));

      // Gestion des appels de fonction (Function Calls)
      // Note: Dans une implémentation complète, nous devrions boucler tant qu'il y a des function calls.
      // Ici, on gère un seul tour pour la démo.

      final functionCalls = response.functionCalls;
      if (functionCalls.isNotEmpty) {
        for (final call in functionCalls) {
          if (call.name == 'createTask') {
            final args = call.args;
            final title = args['title'] as String?;
            final note = args['note'] as String?;
            final dateStr = args['date'] as String?;
            final timeStr = args['time'] as String?;

            if (title != null && dateStr != null && timeStr != null) {
              await _performCreateTask(title, note ?? '', dateStr, timeStr);

              // Envoyer la réponse de la fonction au modèle
              response = await _chat.sendMessage(Content.functionResponse(
                  call.name, {
                'result':
                    'Task "$title" created successfully for $dateStr at $timeStr.'
              }));
            }
          }
        }
      }

      if (response.text != null) {
        setState(() {
          _history
              .add((role: 'model', message: response.text!, isLoading: false));
        });
      }
    } catch (e) {
      setState(() {
        _history.add((role: 'model', message: 'Error: $e', isLoading: false));
      });
    } finally {
      setState(() {
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _performCreateTask(
      String title, String note, String dateStr, String timeStr) async {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final timeParts = timeStr.split(':');
      final time = TimeOfDay(
          hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

      final newTask = Task(
        title: title,
        note: note,
        date: date, // Correct: DateTime
        time:
            '${time.hour}:${time.minute.toString().padLeft(2, '0')}', // Format simple
        category: TaskCategories
            .home, // Correct: Enum value directly or via extension
        isCompleted: false,
      );

      await ref
          .read(taskProvider.notifier)
          .createTask(newTask); // Correct: createTask

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "$title" created!')),
        );
      }
    } catch (e) {
      debugPrint('Error creating task: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final isUser = item.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? colors.primaryContainer
                          : colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(16),
                        bottomLeft:
                            !isUser ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: MarkdownBody(
                      data: item.message,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                            color: isUser
                                ? colors.onPrimaryContainer
                                : colors.onSecondaryContainer),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask me to create a task...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
