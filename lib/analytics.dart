import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'auth_gate.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key}) : super(key: key);

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  DateTime selectedDate = DateTime.now();
  List<CategoryExpense> categoryExpenses = [];

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      AuthGate();
    } catch (error) {
      Text('Error during logout: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Analytics',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),),
          backgroundColor: Colors.red,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: GestureDetector(
                    onTap: () => _selectedDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                          ),
                          labelText: getDateText(),
                          hintText: "Date of Expenditure",
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          suffix: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PieChartSectionData>>(
              future: getSections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No data available for the selected date.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),),
                  );
                } else {
                  return SfCircularChart(
                    legend: Legend(
                      iconHeight: 36,
                      iconWidth: 36,
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      title: LegendTitle(
                      text: 'Expenses',
                        textStyle: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<PieChartSectionData, String>(
                        dataSource: snapshot.data!,
                        xValueMapper: (data, _) => data.title ?? '',
                        yValueMapper: (data, _) => data.value < 0 ? (-1) * data.value: data.value,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<PieChartSectionData>> getSections() async {
    double totalAmount = 0;
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime lastDayOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final userKey = FirebaseAuth.instance.currentUser;
    final querySnapshot = await FirebaseFirestore.instance.collection('expenseTrackerUsers').doc(userKey?.uid).collection('transactions')
        .where(
      'transactionDate',
      isGreaterThanOrEqualTo: firstDayOfMonth,
      isLessThanOrEqualTo: lastDayOfMonth,
    ).get();

    categoryExpenses = querySnapshot.docs
        .map((doc) => CategoryExpense(
      category: doc['transactionCategory'],
      amount: doc['transactionAmount'].toDouble(),
    )).toList();

    categoryExpenses = categoryExpenses.where((expense) => expense.amount < 0).toList();

    if (categoryExpenses.isEmpty) {
      return [];
    }

    List<PieChartSectionData> sections = [];
    for (var expense in categoryExpenses) {
      totalAmount += expense.amount;
    }

    for (var expense in categoryExpenses) {
      double percentage = (expense.amount / totalAmount) * 100;

      sections.add(
        PieChartSectionData(
          color: getCategoryColor(expense.category),
          value: expense.amount,
          title: '${expense.category} : ${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return sections;
  }

  Color getCategoryColor(String iconcolor) {
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
      default:
        return Color(0xff546e7a);
    }
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
      default:
        return Icons.fact_check_outlined;
    }
  }

  bool isDateValid = false;
  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(2101));

    if(pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String getDateText() {
    if(selectedDate == DateTime(DateTime.now().year - 5)) {
      isDateValid = false;
      return 'Date';
    } else {
      isDateValid = true;
      return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    }
  }
}

class CategoryExpense {
  final String category;
  final double amount;

  CategoryExpense({required this.category, required this.amount});
}
