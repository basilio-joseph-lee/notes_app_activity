import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('database');

  runApp(const CupertinoApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
} 

class _MyAppState extends State<MyApp> {
  List<dynamic> todolist = [];
  List<dynamic> filteredList = [];
  TextEditingController _addTask = TextEditingController();
  var box = Hive.box('database');

  String filterMode = "all";
  ScrollController _scrollController = ScrollController(); // Scroll controller

  @override
  void initState() {
    super.initState();
    try {
      todolist = box.get('todo') ?? [];
      todolist = todolist.map((item) {
        return {
          "task": item["task"],
          "status": item["status"] ?? false,
          "pinned": item["pinned"] ?? false,
          "checklist": item["checklist"] ?? false,
          "createdAt": item["createdAt"] ?? DateTime.now(),
        };
      }).toList();
      filteredList = List.from(todolist);
    } catch (e) {
      todolist = [];
      filteredList = [];
    }
  }

  void applyFilter() {
    setState(() {
      if (filterMode == "pinned") {
        filteredList = todolist.where((item) => item['pinned'] == true).toList();
      } else if (filterMode == "checklist") {
        filteredList = todolist.where((item) => item['checklist'] == true).toList();
      } else {
        filteredList = List.from(todolist);
      }
    });
  }

  String formatDateTime(DateTime createdAt) {
    return "${DateFormat('MMM d').format(createdAt)} at ${DateFormat('HH:mm').format(createdAt)}";
  }

  Widget _buildHeader(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final headerColor = isDarkMode ? CupertinoColors.white : CupertinoColors.label;

    if (filterMode == "pinned") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          "Pinned Notes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: headerColor,
          ),
        ),
      );
    } else if (filterMode == "checklist") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(
          "Checklist Items",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: headerColor,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDivider(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final dividerColor = isDarkMode ? CupertinoColors.white.withOpacity(0.1) : CupertinoColors.separator;

    if (filterMode == "pinned" || filterMode == "checklist") {
      return Divider(
        color: dividerColor,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<void> _updateTaskDialog(Map<String, dynamic> item) async {
    TextEditingController _taskController = TextEditingController(text: item['task']);
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Update Note"),
        content: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: CupertinoTextField(
            controller: _taskController,
            placeholder: 'Update Note',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: Text("Save"),
            onPressed: () {
              setState(() {
                item['task'] = _taskController.text;
                int mainIndex = todolist.indexWhere((task) => task['task'] == item['task']);
                if (mainIndex != -1) todolist[mainIndex]['task'] = item['task'];
                box.put('todo', todolist);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    double titleFontSize = isSmallScreen ? 14 : 18;
    double taskFontSize = isSmallScreen ? 12 : 16;
    double dateFontSize = isSmallScreen ? 10 : 12;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Text(
            "Notes",
            style: TextStyle(
              color: CupertinoColors.systemYellow,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              child: const Icon(
                CupertinoIcons.settings,
                color: CupertinoColors.systemYellow,
                size: 20,
              ),
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: const Text("List of Members"),
                      content: Column(
                        children: [
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const SizedBox(height: 15),
                                Flexible( // Added Flexible
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/maryjoyce.jpg',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible( // Added Flexible
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Artienda, Mary Joyce", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "UX designer",
                                              style: TextStyle(color: CupertinoColors.systemGrey2),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                 const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ],
                            ),
                          ),

                            const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const SizedBox(height: 15),
                                Flexible( // Added Flexible
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/aaron.jpg',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Avendano, Aaron Jireh", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "Front-End Developer",
                                              style: TextStyle(color: CupertinoColors.systemGrey2),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const SizedBox(height: 15),
                                Flexible( // Added Flexible
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/joseph.jpg',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Joseph Lee Basilio", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "Data Analyst",
                                              style: TextStyle(color: CupertinoColors.systemGrey2),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const SizedBox(height: 15),
                                Flexible( // Added Flexible
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/joel.jpg',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Dizon, Joel", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "Software Engineer",
                                              style: TextStyle(color: CupertinoColors.systemGrey2),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 5,
                            endIndent: 5,
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                const SizedBox(height: 15),
                                Flexible( // Added Flexible
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/jomel.jpg',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Simbillo, Jomel", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "Cyber Security",
                                              style: TextStyle(color: CupertinoColors.systemGrey2),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  indent: 5,
                                  endIndent: 5,
                                ),
                              ],
                            ),
                          ),