import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
    });
  }

  void _updatePlan(int index, String newName, String newDescription, DateTime newDate) {
    setState(() {
      plans[index].name = newName;
      plans[index].description = newDescription;
      plans[index].date = newDate;
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _showPlanDialog({int? index}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    if (index != null) {
      nameController.text = plans[index].name;
      descController.text = plans[index].description;
      selectedDate = plans[index].date;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Create Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Plan Name')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text('Select Date'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addPlan(nameController.text, descController.text, selectedDate);
                } else {
                  _updatePlan(index, nameController.text, descController.text, selectedDate);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Manager')),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return Draggable<Plan>(
            data: plans[index],
            feedback: Material(
              child: ListTile(
                title: Text(plans[index].name, style: TextStyle(decoration: plans[index].isCompleted ? TextDecoration.lineThrough : null)),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.5,
              child: ListTile(
                title: Text(plans[index].name),
              ),
            ),
            child: GestureDetector(
              onDoubleTap: () => _deletePlan(index),
              child: ListTile(
                title: Text(plans[index].name, style: TextStyle(decoration: plans[index].isCompleted ? TextDecoration.lineThrough : null)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plans[index].description),
                    Text(
                      'Date: ${plans[index].date.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(plans[index].isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () => _toggleCompletion(index),
                ),
                onLongPress: () => _showPlanDialog(index: index),
                onTap: () => _toggleCompletion(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}