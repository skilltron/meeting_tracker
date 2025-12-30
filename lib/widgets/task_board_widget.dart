import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_dialog.dart';
import 'dart:math' as math;

class TaskBoardWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const TaskBoardWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.9),
                const Color(0xFF1F2A4A).withOpacity(0.7),
              ],
            ),
            border: Border.all(
              color: accentColor.withOpacity(0.35),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TASK BOARD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: accentColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showCreateTaskDialog(context, taskProvider);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 14,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NEW TASK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Trello-like columns
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumn(context, 'To Do', TaskStatus.todo, taskProvider),
                    const SizedBox(width: 12),
                    _buildColumn(context, 'In Progress', TaskStatus.inProgress, taskProvider),
                    const SizedBox(width: 12),
                    _buildColumn(context, 'Review', TaskStatus.review, taskProvider),
                    const SizedBox(width: 12),
                    _buildColumn(context, 'Done', TaskStatus.done, taskProvider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildColumn(BuildContext context, String title, TaskStatus status, TaskProvider taskProvider) {
    final tasks = taskProvider.getTasksByStatus(status);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks',
                        style: TextStyle(
                          fontSize: 10,
                          color: textColor.withOpacity(0.4),
                        ),
                      ),
                    )
                  : DragTarget<Task>(
                      onAccept: (draggedTask) {
                        if (draggedTask.status != status) {
                          taskProvider.moveTask(draggedTask.id, status);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: candidateData.isNotEmpty
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              return _buildTaskCard(context, tasks[index], taskProvider);
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
  
  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider taskProvider) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPriorityColor(task.priority).withOpacity(0.3),
                _getPriorityColor(task.priority).withOpacity(0.2),
              ],
            ),
            border: Border.all(
              color: _getPriorityColor(task.priority),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _getPriorityColor(task.priority).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            task.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _showTaskDetailsDialog(context, task, taskProvider);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getPriorityColor(task.priority).withOpacity(0.15),
                _getPriorityColor(task.priority).withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: _getPriorityColor(task.priority).withOpacity(0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.gitIssueNumber != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${task.gitIssueNumber}',
                      style: TextStyle(
                        fontSize: 8,
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (task.assignedTo != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 10,
                    color: accentColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedByName ?? task.assignedTo!,
                    style: TextStyle(
                      fontSize: 9,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
            if (task.dueDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 10,
                    color: accentColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${task.dueDate!.day}/${task.dueDate!.month}',
                    style: TextStyle(
                      fontSize: 9,
                      color: textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
  
  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return accentColor;
      case TaskPriority.low:
        return Colors.grey;
    }
  }
  
  void _showCreateTaskDialog(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        textColor: textColor,
        accentColor: accentColor,
      ),
    );
  }
  
  void _showTaskDetailsDialog(BuildContext context, Task task, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        textColor: textColor,
        accentColor: accentColor,
      ),
    );
  }
}
