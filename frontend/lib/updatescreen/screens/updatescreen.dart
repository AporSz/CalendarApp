import 'package:calendarapp/homescreen/models/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../homescreen/viewmodel/calendar_viewmodel.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key, required this.event});

  final Event event;

  @override
  State<StatefulWidget> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _start;
  late DateTime _end;
  late Color _color;
  late bool _repeating;
  late bool _notifyMe;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _start = event.startDate;
    _end = event.endDate;
    _color = event.color;
    _repeating = event.repeating;
    _notifyMe = event.notifyMe;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isStart}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(1000),
      lastDate: DateTime(3000),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _start : _end),
    );
    if (pickedTime == null) return;

    setState(() {
      final selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (isStart) {
        _start = selectedDateTime;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        _end = selectedDateTime;
      }
    });
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate()) {
      if (_end.isBefore(_start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be after the start date.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final viewModel = context.read<CalendarViewmodel>();

      viewModel.updateEvent(
        widget.event.id,
        _titleController.text,
        _descriptionController.text,
        _start,
        _end,
        _repeating,
        _color,
        _notifyMe,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _updateEvent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 24),

              const Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: Text(DateFormat('EEE, MMM d, yyyy  h:mm a').format(_start))),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context, isStart: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: Text(DateFormat('EEE, MMM d, yyyy  h:mm a').format(_end))),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDateTime(context, isStart: false),
                  ),
                ],
              ),
              const Divider(height: 32),

              SwitchListTile(
                title: const Text('Repeat Event'),
                value: _repeating,
                onChanged: (bool value) {
                  setState(() {
                    _repeating = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Notify Me'),
                value: _notifyMe,
                onChanged: (bool value) {
                  setState(() {
                    _notifyMe = value;
                  });
                },
              ),
              const Divider(height: 32),

              const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _color = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _color == color ? Theme.of(context).primaryColorDark : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: _color == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}