import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  final Map<DateTime, List<String>> events = {};

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  void addEvent(String event) {
    final day = _dateOnly(selectedDay);
    setState(() {
      events.putIfAbsent(day, () => []).add(event);
    });
  }

  Future<void> _showAddEventDialog() async {
    final controller = TextEditingController();

    try {
      final event = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Agregar evento'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Veterinario, peluquería...',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, controller.text.trim());
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      );

      if (!mounted || event == null || event.isEmpty) return;
      addEvent(event);
    } finally {
      controller.dispose();
    }
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
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
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
          const SizedBox(height: 20),
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
