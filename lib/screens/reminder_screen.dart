import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final TextEditingController eventController = TextEditingController();
  final Map<DateTime, List<String>> events = {};

  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
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
      }
    });
  }

  void _saveEvent() {
    final event = eventController.text.trim();

    if (event.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un recordatorio.')),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final day = _dateOnly(selectedDay);

    setState(() {
      events.putIfAbsent(day, () => []).add(event);
      eventController.clear();
      isAddingEvent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = events[_dateOnly(selectedDay)] ?? [];

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
      body: Column(
        children: [
          TableCalendar<String>(
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
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: eventController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _saveEvent(),
                            decoration: const InputDecoration(
                              labelText: 'Nuevo recordatorio',
                              hintText: 'Veterinario, peluquería...',
                              border: OutlineInputBorder(),
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
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(
                            Icons.event,
                            color: Colors.teal,
                          ),
                          title: Text(dayEvents[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
