import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:expense_tracker/transactionDetail.dart' as my_transaction;

import 'auth_gate.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var _budget = 0.0;
  late DocumentSnapshot documentSnapshot;
  var today = DateTime.now();
  var ringdate = DateTime.now();

  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

  getColor(String iconcolor) {
    switch (iconcolor) {
      case 'Education':
        return Color(0xff0293ee);
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
      case 'Grocery':
        return Colors.deepOrangeAccent;
    }
    return Color(0xff546e7a);
  }

  IconData getIcon(String iconstring) {
    switch (iconstring) {
      case 'Education':
        return Icons.book_outlined;
      case 'Rent':
        return Icons.house_outlined;
      case 'Entertainment':
        return Icons.movie_creation_outlined;
      case 'Taxes':
        return Icons.attach_money_outlined;
      case 'Vehicle':
        return Icons.directions_car_outlined;
      case 'Stationary':
        return Icons.edit_outlined;
      case 'Meal':
        return Icons.fastfood_outlined;
      case 'Grocery':
        return Icons.local_grocery_store;
    }
    return Icons.fact_check_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final userKey = FirebaseAuth.instance.currentUser;
    today = DateTime(today.year, today.month, today.day);
    ringdate = DateTime(ringdate.year, ringdate.month);
    var _newtoday = today;

    Future<int> getBudget(userKey) async {
      var check = await FirebaseFirestore.instance
          .collection('expenseTrackerUsers')
          .doc(userKey?.uid)
          .collection('transactions').doc(userKey.hashCode.toString())
          .get();
      if (check.exists) {
        FirebaseFirestore.instance
            .collection('expenseTrackerUsers')
            .doc(userKey?.uid)
            .collection('transactions').doc(userKey.hashCode.toString())
            .get()
            .then((value) {
          documentSnapshot = value;
          setState(() {
            _budget = documentSnapshot['transactionAmount'];
          });
        });
        return documentSnapshot['transactionAmount'];
      }
      return 0;
    }

    MaterialPageRoute _buildTransactionDetailRoute(DocumentSnapshot user) {
      return MaterialPageRoute(
        builder: (context) => my_transaction.TransactionDetailScreen(
          transaction: my_transaction.Transaction(
            transactionId: user.id,
            transactionTitle: user['transactionTitle'],
            transactionAmount: (user['transactionAmount'] ?? 0).toDouble(),
            transactionCategory: user['transactionCategory'],
            transactionDate: (user['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
        ),
      );
    }

    Future<void> _logout(BuildContext context) async {
      try {
        await FirebaseAuth.instance.signOut();
        AuthGate();
      } catch (error) {
        Text('Error during logout: $error');
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),),
      backgroundColor: Colors.orangeAccent,
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
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('expenseTrackerUsers')
              .doc(userKey?.uid)
              .collection('transactions')
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            getBudget(userKey).then((value) {
              if (value > 0) {
                _budget = value.toDouble();
              }
            });
            var totalIncome = 0.0;
            var totalExpense = 0.0;

            snapshot.data!.docs.forEach((user) {
              var transactionAmount = (user['transactionAmount'] ?? 0).toDouble();

              if (transactionAmount > 0) {
                totalIncome += transactionAmount;
              } else {
                totalExpense += transactionAmount.abs();
              }
            });

            var _balance = totalIncome - totalExpense;
            var balchecker = _balance < 0 ? 1 : 0;
            _balance = _balance.abs();

            var _percent = totalIncome != 0.0 && totalExpense != 0.0 ? (totalExpense / totalIncome) : 0.0;
            var _percenttext = _percent * 100.0;
            _percent = double.parse(_percent.toStringAsFixed(2));
            _percenttext = double.parse(_percenttext.toStringAsFixed(2));

            return Container(
              color: Colors.indigoAccent.shade100,
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      padding: EdgeInsets.only(
                        top: 15,
                        left: 35,
                        right: 20,
                      ),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 150,
                            center: Text(
                              _percenttext.toString() + "%",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            progressColor: _percenttext >= 75 ? Colors.red : Colors.green,
                            backgroundColor: Colors.black,
                            percent: _percenttext > 100.0 ? 0 : _percent,
                            lineWidth: 20,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 25,
                                    top: 40,
                                  ),
                                  child: balchecker == 0 ? Text("Balance",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    ),) : Text("OverBudget",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red
                                  ),),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 25),
                                  child: balchecker == 0 ? Text(_balance.toString() + '\$',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                  ),) : Text("By " + _balance.toString() + "\$'",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red
                                  ),),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 500, // Specify a fixed height or use constraints as needed
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      "Showing Recent Transactions",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      DateFormat.yMMMEd().format(_newtoday),
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('expenseTrackerUsers')
                                          .doc(userKey?.uid)
                                          .collection('transactions')
                                          .orderBy('transactionDate', descending: true)
                                          .snapshots(),
                                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (!snapshot.hasData) {
                                          return CircularProgressIndicator();
                                        } else if(snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
                                          return ListView(
                                            children: snapshot?.data?.docs?.map((user) {
                                              Color textColor = user['transactionAmount'] > 0 ? Colors.green : Colors.red;
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    _buildTransactionDetailRoute(user),
                                                  );
                                                },
                                                child: Center(
                                                  child: ListTile(
                                                    leading: Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: getColor(user['transactionCategory']) ?? Colors.grey,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Icon(
                                                        getIcon(user['transactionCategory']) ?? Icons.error,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      user['transactionTitle'] ?? 'Unknown',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      DateFormat('dd MMMM, yyyy')
                                                          .format((user['transactionDate'] as Timestamp?)?.toDate() ?? DateTime.now()) // Handle null
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                      '\$${(user['transactionAmount'] < 0 ? -1 * user['transactionAmount'] : user['transactionAmount'])?.toString() ?? '0'}', // Handle null
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: textColor,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            })?.toList() ?? [],
                                          );
                                        } else {
                                          return Text('No Recent Transactions found', style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold
                                          ),);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}