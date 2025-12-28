import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/meeting_todo.dart';

class MeetingTodoDialog extends StatefulWidget {
  final String meetingId;
  final String meetingTitle;
  
  const MeetingTodoDialog({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  State<MeetingTodoDialog> createState() => _MeetingTodoDialogState();
}

class _MeetingTodoDialogState extends State<MeetingTodoDialog> {
  final TextEditingController _todoController = TextEditingController();
  
  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final todos = todoProvider.getTodosForMeeting(widget.meetingId);
        
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFA8D5BA).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Prepare: ${widget.meetingTitle}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB8D4E3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFB8D4E3),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Add new todo
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        style: const TextStyle(
                          color: Color(0xFFB8D4E3),
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add preparation task...',
                          hintStyle: TextStyle(
                            color: const Color(0xFFB8D4E3).withOpacity(0.5),
                            fontSize: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFA8D5BA).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFA8D5BA).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFA8D5BA),
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF1A1A2E).withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            todoProvider.addTodo(widget.meetingId, value);
                            _todoController.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        if (_todoController.text.trim().isNotEmpty) {
                          todoProvider.addTodo(
                            widget.meetingId,
                            _todoController.text,
                          );
                          _todoController.clear();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8D5BA).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFA8D5BA).withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFFA8D5BA),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Todo list
                Flexible(
                  child: todos.isEmpty
                      ? Center(
                          child: Text(
                            'No preparation tasks yet.\nAdd tasks to prepare for this meeting.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFB8D4E3).withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            return _TodoItem(
                              todo: todo,
                              onToggle: () => todoProvider.toggleTodo(todo.id),
                              onDelete: () => todoProvider.deleteTodo(todo.id),
                              onUpdate: (newText) =>
                                  todoProvider.updateTodo(todo.id, newText),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodoItem extends StatefulWidget {
  final MeetingTodo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onUpdate;
  
  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> {
  bool _isEditing = false;
  late TextEditingController _editController;
  
  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.todo.text);
  }
  
  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo.isCompleted;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFA8D5BA).withOpacity(0.1)
            : const Color(0xFF1A1A2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFA8D5BA).withOpacity(0.3)
              : const Color(0xFFA8D5BA).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFFA8D5BA)
                      : const Color(0xFFA8D5BA).withOpacity(0.5),
                  width: 2,
                ),
                color: isCompleted
                    ? const Color(0xFFA8D5BA).withOpacity(0.3)
                    : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFFA8D5BA),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Todo text
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _editController,
                    style: TextStyle(
                      color: isCompleted
                          ? const Color(0xFFA8D5BA).withOpacity(0.7)
                          : const Color(0xFFB8D4E3),
                      fontSize: 13,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                : GestureDetector(
                    onTap: () => setState(() => _isEditing = true),
                    onLongPress: widget.onDelete,
                    child: Text(
                      widget.todo.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCompleted
                            ? const Color(0xFFA8D5BA).withOpacity(0.7)
                            : const Color(0xFFB8D4E3),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationThickness: 2,
                        decorationColor: const Color(0xFFA8D5BA),
                      ),
                    ),
                  ),
          ),
          
          // Delete button
          GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 16,
                color: const Color(0xFFB8D4E3).withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
