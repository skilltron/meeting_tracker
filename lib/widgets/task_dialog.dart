import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Color textColor;
  final Color accentColor;
  
  const TaskDialog({
    super.key,
    this.task,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _assignedToController;
  late TextEditingController _dueDateController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.todo;
  bool _createGitHubIssue = false;
  DateTime? _dueDate;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _assignedToController = TextEditingController(text: widget.task?.assignedTo ?? '');
    _dueDateController = TextEditingController();
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    
    if (widget.task?.dueDate != null) {
      _dueDate = widget.task!.dueDate;
      _dueDateController.text = '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.accentColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      title: Text(
        widget.task == null ? 'CREATE TASK' : 'EDIT TASK',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: widget.accentColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: widget.textColor, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  color: widget.textColor.withOpacity(0.6),
                  fontSize: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              style: TextStyle(color: widget.textColor, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  color: widget.textColor.withOpacity(0.6),
                  fontSize: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assignedToController,
              style: TextStyle(color: widget.textColor, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Assign To (User ID)',
                labelStyle: TextStyle(
                  color: widget.textColor.withOpacity(0.6),
                  fontSize: 11,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dueDateController,
                    readOnly: true,
                    onTap: _selectDueDate,
                    style: TextStyle(color: widget.textColor, fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: TextStyle(
                        color: widget.textColor.withOpacity(0.6),
                        fontSize: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: widget.accentColor.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: widget.accentColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: widget.accentColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Priority',
              style: TextStyle(
                fontSize: 10,
                color: widget.textColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildPriorityButton('Critical', TaskPriority.critical, Colors.red),
                _buildPriorityButton('High', TaskPriority.high, Colors.orange),
                _buildPriorityButton('Medium', TaskPriority.medium, widget.accentColor),
                _buildPriorityButton('Low', TaskPriority.low, Colors.grey),
              ],
            ),
            if (widget.task != null) ...[
              const SizedBox(height: 16),
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 10,
                  color: widget.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusButton('To Do', TaskStatus.todo),
                  _buildStatusButton('In Progress', TaskStatus.inProgress),
                  _buildStatusButton('Review', TaskStatus.review),
                  _buildStatusButton('Done', TaskStatus.done),
                ],
              ),
            ],
            if (widget.task == null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _createGitHubIssue,
                    onChanged: (value) {
                      setState(() {
                        _createGitHubIssue = value ?? false;
                      });
                    },
                    activeColor: widget.accentColor,
                  ),
                  Expanded(
                    child: Text(
                      'Create GitHub Issue',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: widget.textColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final taskProvider = Provider.of<TaskProvider>(context, listen: false);
            
            if (widget.task == null) {
              // Create new task
              await taskProvider.createTask(
                title: _titleController.text,
                description: _descriptionController.text,
                createdBy: 'current_user', // TODO: Get from auth
                priority: _selectedPriority,
                assignedTo: _assignedToController.text.isNotEmpty
                    ? _assignedToController.text
                    : null,
                dueDate: _dueDate,
                createGitHubIssue: _createGitHubIssue,
              );
            } else {
              // Update existing task
              final updatedTask = widget.task!.copyWith(
                title: _titleController.text,
                description: _descriptionController.text,
                priority: _selectedPriority,
                status: _selectedStatus,
                assignedTo: _assignedToController.text.isNotEmpty
                    ? _assignedToController.text
                    : null,
                dueDate: _dueDate,
              );
              await taskProvider.updateTask(updatedTask);
            }
            
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'SAVE',
            style: TextStyle(
              color: widget.accentColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPriorityButton(String label, TaskPriority priority, Color color) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.3)
              : color.withOpacity(0.1),
          border: Border.all(
            color: isSelected
                ? color
                : color.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? color
                : widget.textColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusButton(String label, TaskStatus status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.accentColor.withOpacity(0.3)
              : widget.accentColor.withOpacity(0.1),
          border: Border.all(
            color: isSelected
                ? widget.accentColor
                : widget.accentColor.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? widget.accentColor
                : widget.textColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
