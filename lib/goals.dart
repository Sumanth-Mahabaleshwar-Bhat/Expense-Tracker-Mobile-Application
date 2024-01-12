import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_gate.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<String> goals = [];
  late CollectionReference goalsCollection;
  late User? currentUser;

  final TextEditingController goalTitleController = TextEditingController();
  final TextEditingController targetDateController = TextEditingController();
  final TextEditingController amountSavedController = TextEditingController();
  final TextEditingController goalAmountController = TextEditingController();
  String? selectedCategory = 'Select Goal Category';
  String pickedDate = '';

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    goalsCollection = FirebaseFirestore.instance
        .collection('expenseTrackerUsers')
        .doc(currentUser?.uid)
        .collection('goals');
    _fetchGoalsfromFirebase();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      AuthGate();
    } catch (error) {
      Text('Error during logout: $error');
    }
  }

  void _fetchGoalsfromFirebase() async {
    if (currentUser != null) {
      try {
        QuerySnapshot<Object?> querySnapshot =
        await goalsCollection.get();

        setState(() {
          if (querySnapshot.docs != null) {
            goals = querySnapshot.docs.map((doc) => doc['title'] as String).toList();
          } else {
            goals = [];
          }
        });
      } catch (error) {
        print('Error fetching goals: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching goals"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User not signed in"),
        ),
      );
    }
  }


  void _addGoaltoFirebase(Map<String, dynamic> goalData) async {
    try {
      if(currentUser != null) {
        await goalsCollection.add({
          'category': goalData['category'],
          'title': goalData['title'],
          'targetDate': goalData['targetDate'],
          'amountSaved': goalData['amountSaved'],
          'goalAmount': goalData['goalAmount'],
          'email': currentUser!.email});
        _fetchGoalsfromFirebase();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User not signed in"),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding goal: $error'),
        ),
      );
    }
  }

  DateTime selectedDate = DateTime.now();
  bool isDateValid = false;
  void _selectedDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        targetDateController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  }

  void _addGoalsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Add a New Goal"),
                  SizedBox(height: 16),
                  TextField(
                    controller: goalTitleController,
                    decoration: InputDecoration(labelText: 'Goal Title'),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    iconSize: 25.0,
                    hint: Text("Select Goal Category"),
                    isExpanded: true,
                    value: selectedCategory,
                    items: <String>[
                      'Select Goal Category',
                      'Education',
                      'Rent',
                      'Entertainment',
                      'Taxes',
                      'Vehicle',
                      'Stationary',
                      'Meal',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            getIcon(value),
                            SizedBox(width: 10.0),
                            Text(value, style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),

                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: GestureDetector(
                          onTap: () => _selectedDate(context),
                          child: TextFormField(
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25.0),
                                ),
                              ),
                              labelText: "Target Date",
                              hintText: "Select Target Date",
                              prefixIcon: Icon(Icons.calendar_today_outlined),
                              suffix: Icon(Icons.arrow_drop_down),
                            ),
                            controller: targetDateController,
                            enabled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountSavedController,
                    decoration: InputDecoration(labelText: 'Amount Saved'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: goalAmountController,
                    decoration: InputDecoration(labelText: 'Goal Amount'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Map<String, dynamic> goalData = {
                            'category': selectedCategory,
                            'title': goalTitleController.text,
                            'targetDate': targetDateController.text,
                            'amountSaved': amountSavedController.text,
                            'goalAmount': goalAmountController.text,
                          };
                          _addGoaltoFirebase(goalData);
                          Navigator.pop(context);
                        },
                        child: Text('Add Goal'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  getColor(String iconcolor) {
    switch (iconcolor) {
      case 'Education':
        return Colors.lightBlueAccent;
      case 'Rent':
        return Color(0xfff8b250);
      case 'Entertainment':
        return Color(0xff845bef);
      case 'Taxes':
        return Color(0xff13d38e);
      case 'Vehicle':
        return Color(0xFF800C32);
      case 'Stationary':
        return Color(0xffd500f9);
      case 'Meal':
        return Color(0xff00695c);
    }
    return Color(0xff546e7a);
  }

  Icon getIcon(String iconstring) {
    switch (iconstring) {
      case 'Education':
        return Icon(Icons.book_outlined);
      case 'Rent':
        return Icon(CupertinoIcons.house);
      case 'Entertainment':
        return Icon(Icons.movie_creation_outlined);
      case 'Taxes':
        return Icon(CupertinoIcons.money_dollar_circle);
      case 'Vehicle':
        return Icon(CupertinoIcons.car_detailed);
      case 'Stationary':
        return Icon(CupertinoIcons.pencil_outline);
      case 'Meal':
        return Icon(Icons.fastfood_outlined);
    }
    return Icon(Icons.fact_check_outlined);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Goals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),),
          backgroundColor: Colors.green,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 10.0,),
                          Text('Sign Out'),
                        ],
                      )
                  ),
                ];
              },
              onSelected: (value) {
                if(value == 0) {
                  _logout(context);
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('expenseTrackerUsers')
              .doc(currentUser?.uid)
              .collection('goals')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            } else if (snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                  String title = data['title'] ?? '';
                  Color goalColor = getColor(data['category']) ?? Colors.white;
                  Icon goalIcon = getIcon(data['category']);
                  return Card(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade100, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            child: goalIcon,
                          ),
                          Text('Goal Category: ${data['category']}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),),
                          Text('Goal Title: ${title}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),),
                          Text('Target Date: ${data['targetDate']}',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),),
                          SizedBox(height :10),
                          Container(
                            child: LinearProgressIndicator(
                              borderRadius: BorderRadius.circular(20),
                              valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                              backgroundColor: Colors.grey,
                              value: double.parse(data['amountSaved'])/double.parse(data['goalAmount']),
                            ),
                            height: 20.0,
                          ),
                          SizedBox(height :10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Amount Saved: ${data['amountSaved']}', style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                              ),),
                              Text('Goal Amount: ${data['goalAmount']}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                ),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            } else {
              return Center(
                child: Text(
                  'No goals available!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                  onPressed: () {
                    _addGoalsDialog(context);
                  },
                child: Text(
                  "Create Goal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                  ),
                ),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}