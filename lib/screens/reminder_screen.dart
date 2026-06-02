import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() =>
      _ReminderScreenState();
}

class _ReminderScreenState
    extends State<ReminderScreen> {

  DateTime selectedDay = DateTime.now();

  final Map<DateTime, List<String>> events = {};

  void addEvent(String event) {

    final day = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    if (events[day] == null) {
      events[day] = [];
    }

    events[day]!.add(event);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final dayEvents = events[
          DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
          )
        ] ??
        [];

    return Scaffold(

      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: Colors.teal,
      ),

    floatingActionButton: FloatingActionButton(

    backgroundColor: Colors.teal,

    onPressed: () {

    final controller =
    TextEditingController();

    showDialog(

    context: context,

    builder: (context) {

    return AlertDialog(

    title:
    const Text('Agregar evento'),

    content: TextField(

    controller: controller,

    decoration:
    const InputDecoration(

    hintText:
    'Veterinario, peluquería...',
    ),
    ),

    actions: [

    TextButton(

    onPressed: () {
    Navigator.pop(context);
    },

    child: const Text('Cancelar'),
    ),

    ElevatedButton(

    onPressed: () {

    if (controller
        .text
        .isNotEmpty) {

    addEvent(
    controller.text,
    );
    }

    Navigator.pop(context);
    },

    child: const Text('Guardar'),
    ),
    ],
    );
    },
    );
    },

    child: const Icon(Icons.add),
    ),

    body: Column(

    children: [

    TableCalendar(

    focusedDay: selectedDay,

    firstDay:
    DateTime(2020),

    lastDay:
    DateTime(2030),

    selectedDayPredicate:
    (day) {

    return isSameDay(
    selectedDay,
    day,
    );
    },

    onDaySelected:
    (selected, focused) {

    setState(() {
    selectedDay = selected;
    });
    },

    calendarStyle:
    const CalendarStyle(

    todayDecoration:
    BoxDecoration(

    color: Colors.teal,

    shape: BoxShape.circle,
    ),

    selectedDecoration:
    BoxDecoration(

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

    ? const Center(

    child: Text(
    'No hay eventos',
    ),
    )

        : ListView.builder(

    itemCount:
    dayEvents.length,

    itemBuilder:
    (context, index) {

    return Card(

    margin:
    const EdgeInsets.all(
    10,
    ),

    child: ListTile(

    leading: const Icon(
    Icons.event,
    color: Colors.teal,
    ),

    title: Text(
    dayEvents[index],
    ),
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