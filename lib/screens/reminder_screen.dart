import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/notification_service.dart';
import '../services/reminder_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final TextEditingController eventController = TextEditingController();
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService.instance;

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAddingEvent = false;

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  @override
  void dispose() {
    eventController.dispose();
    super.dispose();
  }

  void _toggleEventForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      isAddingEvent = !isAddingEvent;
      if (!isAddingEvent) {
        eventController.clear();
        selectedTime = TimeOfDay.now();
      }
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time == null) return;

    setState(() {
      selectedTime = time;
    });
  }

  DateTime _selectedEventDateTime() {
    return DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _saveEvent() async {
    final event = eventController.text.trim();

    if (event.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un recordatorio.')),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final eventDateTime = _selectedEventDateTime();

    try {
      final reminder = await _reminderService.addReminder(
        title: event,
        dateTime: eventDateTime,
      );
      final notificationIds = await _notificationService
          .scheduleReminderNotifications(
            reminderId: reminder.id,
            title: event,
            eventDateTime: eventDateTime,
          );
      await _reminderService.updateNotificationIds(
        reminderId: reminder.id,
        notificationIds: notificationIds,
      );

      if (!mounted) return;

      setState(() {
        eventController.clear();
        selectedTime = TimeOfDay.now();
        isAddingEvent = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio guardado.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $error')),
      );
    }
  }

  Future<void> _editEvent(ReminderEvent reminder) async {
    final result = await showDialog<_ReminderFormResult>(
      context: context,
      builder: (context) => _ReminderFormDialog(reminder: reminder),
    );

    if (result == null) return;

    try {
      await _notificationService.cancelReminderNotifications(
        reminder.notificationIds,
      );
      final notificationIds = await _notificationService
          .scheduleReminderNotifications(
            reminderId: reminder.id,
            title: result.title,
            eventDateTime: result.dateTime,
          );
      await _reminderService.updateReminder(
        reminderId: reminder.id,
        title: result.title,
        dateTime: result.dateTime,
        notificationIds: notificationIds,
      );

      if (!mounted) return;

      setState(() {
        selectedDay = result.dateTime;
        focusedDay = result.dateTime;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio actualizado.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $error')),
      );
    }
  }

  Future<void> _deleteEvent(ReminderEvent reminder) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar recordatorio'),
        content: Text('¿Quieres borrar "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _notificationService.cancelReminderNotifications(
        reminder.notificationIds,
      );
      await _reminderService.deleteReminder(reminder.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio borrado.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo borrar: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _toggleEventForm,
        child: Icon(isAddingEvent ? Icons.close : Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reminderService.watchUserReminders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar recordatorios: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = _groupEvents(snapshot.data!.docs);
          final dayEvents = events[_dateOnly(selectedDay)] ?? [];

          return Column(
            children: [
              TableCalendar<ReminderEvent>(
                focusedDay: focusedDay,
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                eventLoader: (day) => events[_dateOnly(day)] ?? [],
                onDaySelected: (selected, focused) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isAddingEvent
                    ? Padding(
                        key: const ValueKey('event-form'),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          children: [
                            TextField(
                              controller: eventController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _saveEvent(),
                              decoration: const InputDecoration(
                                labelText: 'Nuevo recordatorio',
                                hintText: 'Veterinario, peluquería...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickTime,
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      'Hora: ${selectedTime.format(context)}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton(
                                  onPressed: _saveEvent,
                                  child: const Text('Guardar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Eventos del día',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: dayEvents.isEmpty
                    ? const Center(child: Text('No hay eventos'))
                    : ListView.builder(
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final reminder = dayEvents[index];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: const Icon(
                                Icons.event,
                                color: Colors.teal,
                              ),
                              title: Text(reminder.title),
                              subtitle: Text(
                                'Hora: ${reminder.formattedTime}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editEvent(reminder),
                                  ),
                                  IconButton(
                                    tooltip: 'Borrar',
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteEvent(reminder),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<ReminderEvent>> _groupEvents(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final groupedEvents = <DateTime, List<ReminderEvent>>{};

    for (final doc in docs) {
      final event = ReminderEvent.fromFirestore(doc);
      groupedEvents.putIfAbsent(_dateOnly(event.dateTime), () => []).add(event);
    }

    for (final dayEvents in groupedEvents.values) {
      dayEvents.sort((first, second) => first.dateTime.compareTo(second.dateTime));
    }

    return groupedEvents;
  }
}

class ReminderEvent {
  const ReminderEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.notificationIds,
  });

  factory ReminderEvent.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['dateTime'];
    final dateTime = timestamp is Timestamp
        ? timestamp.toDate()
        : DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now();
    final notificationIds = (data['notificationIds'] as List<dynamic>? ?? [])
        .whereType<int>()
        .toList();

    return ReminderEvent(
      id: doc.id,
      title: data['title'] as String? ?? 'Sin título',
      dateTime: dateTime,
      notificationIds: notificationIds,
    );
  }

  final String id;
  final String title;
  final DateTime dateTime;
  final List<int> notificationIds;

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _ReminderFormDialog extends StatefulWidget {
  const _ReminderFormDialog({required this.reminder});

  final ReminderEvent reminder;

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  late final TextEditingController _titleController;
  late DateTime _date;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder.title);
    _date = widget.reminder.dateTime;
    _time = TimeOfDay.fromDateTime(widget.reminder.dateTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    setState(() {
      _date = date;
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _time,
    );

    if (time == null) return;

    setState(() {
      _time = time;
    });
  }

  String _formattedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      _ReminderFormResult(
        title: title,
        dateTime: DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar recordatorio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Recordatorio',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month),
            label: Text('Fecha: ${_formattedDate(_date)}'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text('Hora: ${_time.format(context)}'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _ReminderFormResult {
  const _ReminderFormResult({required this.title, required this.dateTime});

  final String title;
  final DateTime dateTime;
}
