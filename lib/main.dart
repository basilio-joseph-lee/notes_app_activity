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
                                Flexible(
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.asset(
                                          'images/rachelle.jpg',
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
                                            Text("Macalino, Rachelle Anne", overflow: TextOverflow.ellipsis,),
                                            Text(
                                              "Back-End Developer",
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
                        ],
                      ),







                      actions: [
                        CupertinoButton(
                          child: const Text(
                            "CLose",
                            style: TextStyle(color: CupertinoColors.destructiveRed),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.pin, color: CupertinoColors.systemYellow),
                onPressed: () {
                  setState(() {
                    filterMode = "pinned";
                    applyFilter();
                  });
                },
              ),
            ),

              Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.check_mark_circled,
                    color: CupertinoColors.systemYellow),
                onPressed: () {
                  setState(() {
                    filterMode = "checklist";
                    applyFilter();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.list_bullet,
                    color: CupertinoColors.systemYellow),
                onPressed: () {
                  setState(() {
                    filterMode = "all";
                    applyFilter();
                  });
                },
              ),
            )
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                onChanged: (value) {
                  setState(() {
                    filteredList = todolist
                        .where((item) => item['task']
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            _buildHeader(context),
            _buildDivider(context),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Use the scroll controller
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  return GestureDetector(
                    onDoubleTap: () {
                      _updateTaskDialog(item); // Handle double tap to update task
                    },
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: CupertinoColors.destructiveRed,
                        child: const Icon(CupertinoIcons.delete_simple,
                            color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        bool confirm = false;
                        await showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text("Delete Notes",
                                style: TextStyle(fontSize: titleFontSize)),
                            content: Text("Remove '${item['task']}'?",
                                style: TextStyle(fontSize: taskFontSize)),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  confirm = true;
                                  Navigator.of(context).pop();
                                },
                                child: Text("Yes",
                                    style: TextStyle(
                                        color: CupertinoColors.systemRed,
                                        fontSize: taskFontSize)),
                              ),
                              CupertinoDialogAction(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("No",
                                    style: TextStyle(fontSize: taskFontSize)),
                              )
                            ],
                          ),
                        );
                        return confirm;
                      },

                      onDismissed: (_) {
                        setState(() {
                          todolist.removeWhere(
                                  (element) => element['task'] == item['task']);
                          applyFilter();
                          box.put('todo', todolist);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGroupedBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['task'],
                                      style: TextStyle(
                                        fontSize: taskFontSize,
                                        color: Colors.black,
                                        decoration: (item['status'] ?? false)
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDateTime(item['createdAt']),
                                      style: TextStyle(
                                        fontSize: dateFontSize,
                                        color: CupertinoColors.inactiveGray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Divider(color: CupertinoColors.systemFill),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Icon(
                                      item['checklist'] == true
                                          ? CupertinoIcons.check_mark_circled_solid
                                          : CupertinoIcons.check_mark_circled,
                                      color: item['checklist'] == true
                                          ? CupertinoColors.activeGreen
                                          : CupertinoColors.inactiveGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        item['checklist'] = !(item['checklist'] ?? false);
                                        int mainIndex = todolist.indexWhere((task) => task['task'] == item['task']);
                                        if (mainIndex != -1) todolist[mainIndex]['checklist'] = item['checklist'];
                                        box.put('todo', todolist);
                                      });
                                    },
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: Icon(
                                      item['pinned'] == true ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                                      color: item['pinned'] == true
                                          ? CupertinoColors.systemYellow
                                          : CupertinoColors.inactiveGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        item['pinned'] = !(item['pinned'] ?? false);
                                        int mainIndex = todolist.indexWhere((task) => task['task'] == item['task']);
                                        if (mainIndex != -1) todolist[mainIndex]['pinned'] = item['pinned'];
                                        box.put('todo', todolist);
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: CupertinoColors.systemFill.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${todolist.length} Notes", style: TextStyle(fontSize: titleFontSize)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.square_pencil, color: CupertinoColors.systemYellow),
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text("Add Notes", style: TextStyle(fontSize: titleFontSize)),
                            content: Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 10),
                              child: CupertinoTextField(
                                placeholder: 'Add to Do',
                                controller: _addTask,
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: Text("Cancel", style: TextStyle(color: CupertinoColors.destructiveRed, fontSize: taskFontSize)),
                                onPressed: () {
                                  _addTask.clear();
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text("Add", style: TextStyle(color: CupertinoColors.activeGreen, fontSize: taskFontSize)),
                                onPressed: () {
                                  final createdAt = DateTime.now();
                                  setState(() {
                                    todolist.add({
                                      "task": _addTask.text,
                                      "status": false,
                                      "pinned": false,
                                      "checklist": false,
                                      "createdAt": createdAt,
                                    });
                                    applyFilter();
                                    box.put('todo', todolist);
                                  });
                                  _addTask.clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
