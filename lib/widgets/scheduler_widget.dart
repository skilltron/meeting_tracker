import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';

class SchedulerWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const SchedulerWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<SchedulerWidget> createState() => _SchedulerWidgetState();
}

class _SchedulerWidgetState extends State<SchedulerWidget> {
  bool _showForm = false;
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = _addHoursToTimeOfDay(TimeOfDay.now(), 1);
  
  static TimeOfDay _addHoursToTimeOfDay(TimeOfDay time, int hours) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final newDateTime = dateTime.add(Duration(hours: hours));
    return TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
  }
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  CalendarProviderType _selectedProvider = CalendarProviderType.google;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showForm = !_showForm),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.accentColor.withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'SCHEDULE MEETING',
              style: TextStyle(
                fontSize: 11,
                color: widget.textColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        
        if (_showForm) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.8),
              border: Border.all(
                color: widget.accentColor.withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.2),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEW MEETING',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(_titleController, 'Title'),
                const SizedBox(height: 8),
                _buildDatePicker(),
                const SizedBox(height: 8),
                _buildTimePickers(),
                const SizedBox(height: 8),
                _buildTextField(_locationController, 'Location (optional)'),
                const SizedBox(height: 8),
                _buildProviderSelector(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton('CREATE', _createMeeting),
                    const SizedBox(width: 8),
                    _buildButton('CANCEL', () => setState(() => _showForm = false)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: TextStyle(color: widget.textColor, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: widget.textColor.withOpacity(0.7),
          fontSize: 11,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.accentColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.accentColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.accentColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: const Color(0xFF1A1A2E).withOpacity(0.5),
      ),
    );
  }
  
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.accentColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A2E).withOpacity(0.5),
        ),
        child: Text(
          'Date: ${_selectedDate.toString().split(' ')[0]}',
          style: TextStyle(color: widget.textColor, fontSize: 12),
        ),
      ),
    );
  }
  
  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1A2E).withOpacity(0.5),
              ),
              child: Text(
                'Start: ${_startTime.format(context)}',
                style: TextStyle(color: widget.textColor, fontSize: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1A1A2E).withOpacity(0.5),
              ),
              child: Text(
                'End: ${_endTime.format(context)}',
                style: TextStyle(color: widget.textColor, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProviderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.accentColor.withOpacity(0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A2E).withOpacity(0.5),
      ),
      child: DropdownButton<CalendarProviderType>(
        value: _selectedProvider,
        dropdownColor: const Color(0xFF1A1A2E),
        style: TextStyle(color: widget.textColor, fontSize: 12),
        underline: const SizedBox(),
        isExpanded: true,
      items: const [
        DropdownMenuItem(
          value: CalendarProviderType.google,
          child: Text('Google Calendar'),
        ),
        DropdownMenuItem(
          value: CalendarProviderType.outlook,
          child: Text('Microsoft Outlook'),
        ),
        DropdownMenuItem(
          value: CalendarProviderType.onedrive,
          child: Text('OneDrive / Windows Calendar'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedProvider = value);
        }
      },
      ),
    );
  }
  
  Widget _buildButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.accentColor.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor.withOpacity(0.15),
              blurRadius: 8,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: widget.textColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
  
  Future<void> _createMeeting() async {
    if (_titleController.text.trim().isEmpty) {
      return;
    }
    
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    final end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );
    
    try {
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      await calendarProvider.createEvent(
        title: _titleController.text.trim(),
        start: start,
        end: end,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        provider: _selectedProvider,
      );
      
      setState(() {
        _showForm = false;
        _titleController.clear();
        _locationController.clear();
        _descriptionController.clear();
      });
    } catch (e) {
      // Handle error
      debugPrint('Error creating meeting: $e');
    }
  }
}
