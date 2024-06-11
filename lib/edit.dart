import 'package:flutter/material.dart';
import 'package:task/MongoDbModel.dart';
import 'package:task/db/mongodb.dart';
import 'package:intl/intl.dart';

class MongodbEdit extends StatefulWidget {
  final Welcome data;

  const MongodbEdit({required this.data, Key? key}) : super(key: key);

  @override
  _MongodbEditState createState() => _MongodbEditState();
}

class _MongodbEditState extends State<MongodbEdit> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _statusController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data.title);
    _descriptionController =
        TextEditingController(text: widget.data.description);
    _dateController = TextEditingController(text: widget.data.date);
    _statusController = TextEditingController(text: widget.data.status);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _updateData() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updatedData = Welcome(
        id: widget.data.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        status: _statusController.text,
      );

      await MongoDatabase.update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task Updated")),
      );

      Navigator.of(context).pop(updatedData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update task")),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Task Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _updateData,
                  child: _isUpdating
                      ? CircularProgressIndicator()
                      : Text("Update Task"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, color: Colors.black),
                    foregroundColor: Colors.black, // Set text color to black
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
