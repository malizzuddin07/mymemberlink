import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_member_link/models/events.dart';
import 'package:my_member_link/myconfig.dart';
import 'package:my_member_link/views/edit_events.dart';
import 'package:my_member_link/views/new_events.dart';
import 'package:my_member_link/views/mydrawer.dart';
import 'package:http/http.dart' as http;

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Events> eventsList = [];
  List<Events> filteredEvents = [];
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String query = "";
  int numofpage = 1;
  int curpage = 1;
  late double screenWidth, screenHeight;
  bool isLoading = false;
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadEventsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadEventsData,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredEvents.isEmpty
                  ? Center(
                      child: Text(
                        status,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : Expanded(
                      child: GridView.count(
                        childAspectRatio: 0.75,
                        crossAxisCount: 2,
                        children: List.generate(filteredEvents.length, (index) {
                          return _buildEventCard(index);
                        }),
                      ),
                    ),
          _buildPaginationControls(),
        ],
      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (content) => const NewEventScreen()),
          );
          loadEventsData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            query = value.toLowerCase();
            filteredEvents = eventsList
                .where((event) =>
                    event.eventTitle!.toLowerCase().contains(query) ||
                    event.eventDescription!.toLowerCase().contains(query))
                .toList();
          });
        },
        decoration: InputDecoration(
          hintText: "Search events...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(int index) {
    return Card(
      child: InkWell(
        splashColor: Colors.red,
        onLongPress: () {
          deleteDialog(index);
        },
        onTap: () {
          showEventDetailsDialog(index);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Column(
            children: [
              Text(
                filteredEvents[index].eventTitle.toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis),
              ),
              SizedBox(
                child: Image.network(
                  "${MyConfig.servername}/memberlink/assets/events/${filteredEvents[index].eventFilename}",
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 100,
                    child: Image(image: AssetImage("assets/images/na.png")),
                  ),
                  width: screenWidth / 2,
                  height: screenHeight / 6,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Text(
                  filteredEvents[index].eventType.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Text(df.format(
                  DateTime.parse(filteredEvents[index].eventDate.toString()))),
              Text(truncateString(
                  filteredEvents[index].eventDescription.toString(), 45)),
            ],
          ),
        ),
      ),
    );
  }

  void showEventDetailsDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(filteredEvents[index].eventTitle.toString()),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.network(
                  "${MyConfig.servername}/memberlink/assets/events/${filteredEvents[index].eventFilename}",
                  errorBuilder: (context, error, stackTrace) =>
                      const Image(image: AssetImage("assets/images/na.png")),
                  width: screenWidth,
                  height: screenHeight / 4,
                  fit: BoxFit.cover,
                ),
                Text(filteredEvents[index].eventType.toString()),
                Text(df.format(DateTime.parse(
                    filteredEvents[index].eventDate.toString()))),
                Text(filteredEvents[index].eventLocation.toString()),
                const SizedBox(height: 10),
                Text(
                  filteredEvents[index].eventDescription.toString(),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                Events event = filteredEvents[index]; // Getting the event
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (content) => EditEventScreen(
                        myevent: event), // Passing 'myevent' correctly
                  ),
                );
                loadEventsData();
              },
              child: const Text("Edit Event"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void deleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete \"${truncateString(filteredEvents[index].eventTitle.toString(), 20)}\"",
            style: const TextStyle(fontSize: 18),
          ),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                deleteEvent(index);
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void deleteEvent(int index) async {
    String eventId = filteredEvents[index].eventId.toString();

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/memberlink/api/delete_event.php"),
        body: {"eventid": eventId},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            filteredEvents.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Event deleted successfully."),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete event."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        showErrorSnackbar("Error connecting to server: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackbar("An unexpected error occurred: $e");
    }
  }

  String truncateString(String str, int length) {
    return (str.length > length) ? "${str.substring(0, length)}..." : str;
  }

  void loadEventsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
                "${MyConfig.servername}/memberlink/api/load_events.php?pageno=$curpage"),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == "success") {
          setState(() {
            eventsList = (data['data']['events'] as List)
                .map<Events>((item) => Events.fromJson(item))
                .toList();
            filteredEvents = List.from(eventsList);
            numofpage = int.parse(data['numofpage'].toString());
          });
        } else {
          showErrorSnackbar(data['message']);
        }
      } else {
        showErrorSnackbar("Error connecting to server: ${response.statusCode}");
      }
    } catch (e) {
      showErrorSnackbar("An unexpected error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: curpage > 1
                ? () {
                    setState(() {
                      curpage--;
                    });
                    loadEventsData();
                  }
                : null,
            child: const Text("Previous"),
          ),
          Text("Page $curpage of $numofpage"),
          ElevatedButton(
            onPressed: curpage < numofpage
                ? () {
                    setState(() {
                      curpage++;
                    });
                    loadEventsData();
                  }
                : null,
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }
}
