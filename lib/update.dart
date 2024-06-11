import 'package:flutter/material.dart';
import 'package:task/MongoDbModel.dart';
import 'package:task/db/mongodb.dart';
import 'package:task/insert.dart';
import 'package:task/edit.dart'; // Import the edit screen
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;

class MongodbUpdate extends StatefulWidget {
  const MongodbUpdate({Key? key}) : super(key: key);

  @override
  _MongodbUpdateState createState() => _MongodbUpdateState();
}

class _MongodbUpdateState extends State<MongodbUpdate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks List'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: MongoDatabase.getData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return displayCard(Welcome.fromJson(snapshot.data[index]));
                  },
                );
              } else {
                return Center(
                  child: Text("No Data Found"),
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return MongodbInsert();
              },
            ),
          ).then((value) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget displayCard(Welcome data) {
    Color statusColor = data.status == 'Completed'
        ? Colors.green
        : Color.fromARGB(196, 215, 205, 114);

    DateTime parsedDate;

    try {
      // Try parsing using the expected format 'MM/dd/yyyy'
      parsedDate = DateFormat('MM/dd/yyyy').parse(data.date);
    } catch (e) {
      try {
        // If parsing fails, attempt to parse using another format
        parsedDate = DateFormat('yyyy-MM-dd').parse(data.date);
      } catch (e) {
        // If parsing fails again, fallback to a default value
        parsedDate = DateTime.now();
      }
    }

    // Format the parsed date for display
    String formattedDate = DateFormat.yMMMMd().format(parsedDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(data.description),
            SizedBox(height: 10),
            Text(
              formattedDate, // Display formatted date
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.status,
                  style: TextStyle(color: statusColor),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _deleteData(data.id);
                        setState(() {});
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                    IconButton(
                      onPressed: () async {
                        final updatedData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                MongodbEdit(data: data),
                          ),
                        );

                        if (updatedData != null) {
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.edit, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteData(M.ObjectId id) async {
    await MongoDatabase.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Deleted ID: ${id.toHexString()}")),
    );
  }
}
