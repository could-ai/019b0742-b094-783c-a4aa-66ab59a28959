import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/routine_item.dart';
import '../widgets/character_widget.dart';
import '../widgets/speech_bubble.dart';
import 'add_routine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<RoutineItem> _routines = [];
  String _characterMessage = "Hi there! I'm your Routine Buddy.\nAdd a task and I'll remind you!";
  bool _isCharacterSpeaking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check time every second to trigger reminders
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkRoutine();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkRoutine() {
    final now = TimeOfDay.now();
    bool foundActiveTask = false;

    for (var routine in _routines) {
      // Simple check: matches hour and minute
      if (routine.time.hour == now.hour && routine.time.minute == now.minute) {
        if (!routine.isCompleted) {
          // Trigger the character
          if (_characterMessage != "It's time to: ${routine.title}!") {
            setState(() {
              _characterMessage = "It's time to: ${routine.title}!";
              _isCharacterSpeaking = true;
            });
            
            // Show a dialog or snackbar as a "pop out" reminder
            _showReminderDialog(routine);
          }
          foundActiveTask = true;
        }
      }
    }

    // Reset speaking state if no active task matches right now (optional logic)
    // For now, we keep the message until the minute passes or user dismisses
    if (!foundActiveTask && _isCharacterSpeaking) {
       // We could auto-reset, but let's leave the message for a bit
       // Or reset after the minute changes. 
       // Let's just toggle the "animation" of speaking off after a few seconds
       if (_isCharacterSpeaking) {
         Future.delayed(const Duration(seconds: 3), () {
           if (mounted) {
             setState(() {
               _isCharacterSpeaking = false;
             });
           }
         });
       }
    }
  }

  void _showReminderDialog(RoutineItem routine) {
    // Prevent multiple dialogs for the same minute if possible, 
    // but for simplicity we rely on the message check above to only trigger once per text change.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.alarm, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text('It is ${routine.time.format(context)}'),
            const SizedBox(height: 8),
            Text(
              routine.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markAsDone(routine);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _markAsDone(RoutineItem routine) {
    setState(() {
      routine.isCompleted = true;
      _characterMessage = "Great job completing: ${routine.title}!";
      _isCharacterSpeaking = true;
    });
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _characterMessage = "What's next on the schedule?";
          _isCharacterSpeaking = false;
        });
      }
    });
  }

  void _addRoutine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
    );

    if (result != null && result is Map) {
      setState(() {
        _routines.add(RoutineItem(
          id: DateTime.now().toString(),
          title: result['title'],
          time: result['time'],
        ));
        _routines.sort((a, b) {
          final aMinutes = a.time.hour * 60 + a.time.minute;
          final bMinutes = b.time.hour * 60 + b.time.minute;
          return aMinutes.compareTo(bMinutes);
        });
        _characterMessage = "I've added '${result['title']}' to your routine.";
        _isCharacterSpeaking = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isCharacterSpeaking = false;
          });
        }
      });
    }
  }

  void _deleteRoutine(RoutineItem routine) {
    setState(() {
      _routines.remove(routine);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routine Buddy'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Character Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SpeechBubble(message: _characterMessage),
                const SizedBox(height: 10),
                CharacterWidget(isSpeaking: _isCharacterSpeaking),
              ],
            ),
          ),
          const Divider(height: 40, thickness: 2),
          // Routine List
          Expanded(
            child: _routines.isEmpty
                ? Center(
                    child: Text(
                      'No routines set yet.\nTap + to add one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: _routines.length,
                    itemBuilder: (context, index) {
                      final routine = _routines[index];
                      return Dismissible(
                        key: Key(routine.id),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) => _deleteRoutine(routine),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: routine.isCompleted
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            child: Icon(
                              routine.isCompleted ? Icons.check : Icons.access_time,
                              color: routine.isCompleted
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(
                            routine.title,
                            style: TextStyle(
                              decoration: routine.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(routine.time.format(context)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteRoutine(routine),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRoutine,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
