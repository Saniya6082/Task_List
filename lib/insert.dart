import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:task/MongoDbModel.dart';
import 'package:task/db/mongodb.dart';
import 'package:task/update.dart'; // Import MongodbUpdate screen

class MongodbInsert extends StatefulWidget {
  const MongodbInsert({Key? key}) : super(key: key);

  @override
  State<MongodbInsert> createState() => _MongoState();
}

class _MongoState extends State<MongodbInsert> {
  var titleController = TextEditingController();
  var descController = TextEditingController();
  var dateController = TextEditingController();
  var statusController = TextEditingController();

  bool _isCompleted = false; // Checkbox value
  var _checkInsertUpdate = "Insert";

  @override
  Widget build(BuildContext context) {
    Welcome? data = ModalRoute.of(context)!.settings.arguments as Welcome?;

    if (data != null) {
      titleController.text = data.title;
      descController.text = data.description;
      dateController.text = data.date;
      _isCompleted = data.status == "Completed";
      _checkInsertUpdate = "Update";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_checkInsertUpdate + ' Task'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Task Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dateController,
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
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text("Completed:", style: TextStyle(fontSize: 16)),
                    Checkbox(
                      value: _isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          _isCompleted = value ?? false;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        if (_checkInsertUpdate == "Update") {
                          _updateData(
                            data!.id,
                            titleController.text,
                            descController.text,
                            dateController.text,
                            _isCompleted ? "Completed" : "In Progress",
                          );
                        } else {
                          _insertData(
                            titleController.text,
                            descController.text,
                            dateController.text,
                            _isCompleted ? "Completed" : "In Progress",
                          );
                        }
                      }
                    },
                    child: Text(_checkInsertUpdate + ' Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 16, color: Colors.black),
                      foregroundColor: Colors.black, // Set text color to black
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_validateInputs()) {
            if (_checkInsertUpdate == "Update") {
              _updateData(
                data!.id,
                titleController.text,
                descController.text,
                dateController.text,
                _isCompleted ? "Completed" : "In Progress",
              );
            } else {
              _insertData(
                titleController.text,
                descController.text,
                dateController.text,
                _isCompleted ? "Completed" : "In Progress",
              );
            }
          }
        },
        child: Icon(Icons.save),
        backgroundColor: Colors.teal,
      ),
    );
  }

  bool _validateInputs() {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return false;
    }

    try {
      DateFormat('yyyy-MM-dd').parse(dateController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid date format")),
      );
      return false;
    }

    return true;
  }

  Future<void> _updateData(M.ObjectId id, String title, String desc,
      String date, String status) async {
    final updateData = Welcome(
      id: id,
      title: title,
      description: desc,
      date: date,
      status: status,
    );
    await MongoDatabase.update(updateData)
        .whenComplete(() => Navigator.pop(context));
  }

  Future<void> _insertData(
      String title, String desc, String date, String status) async {
    var _id = M.ObjectId(); // used for unique id
    final data = Welcome(
      id: _id,
      title: title,
      description: desc,
      date: date,
      status: status,
    );

    await MongoDatabase.insert(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Inserted ID: " + _id.toHexString())),
    );

    // Navigate to MongodbUpdate after inserting data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MongodbUpdate()),
    );
  }

  void _clearAll() {
    titleController.text = "";
    descController.text = "";
    dateController.text = "";
    _isCompleted = false;
  }

  void _fakedata() {
    setState(() {
      // Format the date
      final formattedDate =
          DateFormat('yyyy-MM-dd').format(faker.date.dateTime());
      dateController.text = formattedDate;

      _isCompleted = faker.randomGenerator.boolean();

      // Insert the generated data into the database
      _insertData(
        titleController.text,
        descController.text,
        dateController.text,
        _isCompleted ? "Completed" : "In Progress",
      );
    });
  }
}
