import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/messaging_provider.dart';
import '../models/message.dart';

class ScribeWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const ScribeWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<ScribeWidget> createState() => _ScribeWidgetState();
}

class _ScribeWidgetState extends State<ScribeWidget> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  MessagePriority _selectedPriority = MessagePriority.normal;
  bool _forceImmediate = false;
  
  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MessagingProvider>(
      builder: (context, messagingProvider, child) {
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
              color: widget.accentColor.withOpacity(0.35),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCRIBE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: widget.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // To field
              TextField(
                controller: _toController,
                style: TextStyle(color: widget.textColor, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'To (User ID)',
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
              
              // Subject field
              TextField(
                controller: _subjectController,
                style: TextStyle(color: widget.textColor, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Subject',
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
              
              // Content field
              TextField(
                controller: _contentController,
                maxLines: 5,
                style: TextStyle(color: widget.textColor, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Message',
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
              
              // Priority and immediate send
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildPriorityButton('Normal', MessagePriority.normal),
                            const SizedBox(width: 4),
                            _buildPriorityButton('Priority', MessagePriority.priority),
                            const SizedBox(width: 4),
                            _buildPriorityButton('Urgent', MessagePriority.urgent),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _forceImmediate,
                            onChanged: (value) {
                              setState(() {
                                _forceImmediate = value ?? false;
                              });
                            },
                            activeColor: widget.accentColor,
                          ),
                          Text(
                            'Send Now',
                            style: TextStyle(
                              fontSize: 10,
                              color: widget.textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Send button
              GestureDetector(
                onTap: () async {
                  if (_toController.text.isEmpty || _subjectController.text.isEmpty) {
                    return;
                  }
                  
                  final scheduledFor = _forceImmediate || _selectedPriority != MessagePriority.normal
                      ? null
                      : Message.calculateScheduledTime(_selectedPriority);
                  
                  await messagingProvider.sendMessage(
                    fromUserId: 'current_user', // TODO: Get from auth
                    toUserId: _toController.text,
                    subject: _subjectController.text,
                    content: _contentController.text,
                    priority: _selectedPriority,
                    forceImmediate: _forceImmediate,
                  );
                  
                  // Clear form
                  _toController.clear();
                  _subjectController.clear();
                  _contentController.clear();
                  setState(() {
                    _selectedPriority = MessagePriority.normal;
                    _forceImmediate = false;
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          scheduledFor != null
                              ? 'Message scheduled for ${scheduledFor.toString().substring(0, 16)}'
                              : 'Message sent',
                        ),
                        backgroundColor: widget.accentColor.withOpacity(0.8),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor.withOpacity(0.3),
                        widget.accentColor.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: widget.accentColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SEND MESSAGE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              
              // Scheduled messages indicator
              if (messagingProvider.scheduledMessages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: widget.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${messagingProvider.scheduledMessages.length} scheduled',
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPriorityButton(String label, MessagePriority priority) {
    final isSelected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
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
