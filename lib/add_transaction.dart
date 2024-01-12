import 'dart:ffi';
import 'package:expense_tracker/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';

class DropdownItem {
  const DropdownItem(this.name, this.icon);
  final String name;
  final Icon icon;
}

class Transaction {
  final String transactionId;
  final String transactionTitle;
  final double transactionAmount;
  final String transactionCategory;
  final DateTime transactionDate;

  Transaction({
    required this.transactionId,
    required this.transactionTitle,
    required this.transactionAmount,
    required this.transactionCategory,
    required this.transactionDate,
  });
}

class Add_Transaction extends StatefulWidget {
  const Add_Transaction({Key? key}) : super(key: key);

  @override
  __AddTransactionState createState() => __AddTransactionState();
}

class __AddTransactionState extends State<Add_Transaction> {
  final formKey = GlobalKey<FormState>();
  String dropdownValues = 'None';
  bool isIncome = false;

  final transactionCategory = [
    const DropdownItem(
      'None',
      Icon(Icons.text_rotation_none_outlined),
    ),
    const DropdownItem(
        'Education',
        Icon(Icons.book_outlined,
          color: Color(0xFF000000),
        ),
    ),
    const DropdownItem(
      'Rent',
      Icon(Icons.house,
        color: Color(0xFF000000),
      ),
    ),
    const DropdownItem(
      'Entertainment',
      Icon(Icons.movie_creation_outlined,
        color: Color(0xFF000000),
      ),
    ),
    const DropdownItem(
      'Vehicle',
      Icon(Icons.car_crash_outlined,
        color: Color(0xFF000000),
      ),
    ),
    const DropdownItem(
      'Meal',
      Icon(Icons.fastfood_outlined,
        color: Color(0xFF000000),
      ),
    ),
    const DropdownItem(
      'Grocery',
      Icon(Icons.local_grocery_store_outlined,
        color: Color(0xFF000000),
      ),
    ),
    const DropdownItem(
      'Miscellanous',
      Icon(Icons.miscellaneous_services_outlined,
        color: Color(0xFF000000),
      ),
    ),
  ];

  TextEditingController transactionTitle = new TextEditingController();
  TextEditingController amountInfo = new TextEditingController();

  DateTime selectedDate = DateTime.now();
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

  void showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        "Expense added",
        style: TextStyle(fontSize: 18.0, color: Colors.black),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.grey,
      duration: Duration(seconds: 5),
      shape: StadiumBorder(),
      behavior: SnackBarBehavior.floating,
      elevation: 0.0,
      width: 200,
    );
  }

  void _submitTransaction() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('expenseTrackerUsers')
            .doc(currentUser.uid)
            .collection('transactions')
            .add({
          'transactionAmount': isIncome ? double.parse(amountInfo.text) : -double.parse(amountInfo.text),
          'transactionTitle': transactionTitle.text,
          'transactionCategory': isIncome ? 'Income' : dropdownValues,
          'transactionDate': selectedDate,
        });
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('User not signed in!');
      }
    } catch (error) {
      print('Error adding transaction: $error');
    }
  }


  Widget _showInputFieldsBasedOnType(bool isIncomeFlg) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if(isIncomeFlg) {
      return Builder(
          builder: (context) => SafeArea(
              child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        TextField(
                          controller: transactionTitle,
                          decoration: InputDecoration(labelText: "Input Income Transaction Title"),
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: amountInfo,
                          decoration: InputDecoration(labelText: "Input Income Amount"),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _submitTransaction,
                          label: Text('Save Income', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),),
                          icon: Icon(Icons.save),
                        ),
                      ],
                    ),
                  ),
              ),
          ),
      );
    } else {
      return Builder(
        builder: (context) =>  SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  Center(
                    child: Text("New Transaction", style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  SizedBox(height: 5),
                  Text("Track all your expenses and incomes!", style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.grey,
                    indent: 0,
                  ),
                  SizedBox(height: 10),
                  Form(
                    key: formKey,
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 15.0,),
                          TextFormField(
                            controller: transactionTitle,
                            decoration: InputDecoration(
                                labelText: 'Transaction Title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                ),
                                prefixIcon: Icon(Icons.title),
                                hintText: "Please Enter Transaction Title"
                            ),
                            validator: (value) {
                              if(value == null) {
                                return "Transaction Title field is mandatory";
                              } else if(value.length < 2) {
                                return "Please enter valid Transaction Title";
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(height: 20.0,),
                          TextFormField(
                            controller: amountInfo,
                            decoration: InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                                ),
                                prefixIcon: Icon(Icons.local_atm),
                                hintText: "Please Enter Amount"
                            ),
                            validator: (value) {
                              if(value == null) {
                                return "Amount field is mandatory";
                              } else if(value.length <= 0) {
                                return "Please enter valid Transaction Title";
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(height: 20.0,),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                iconSize: 25.0,
                                hint: Text("Select category of Transaction"),
                                isExpanded: true,
                                value: dropdownValues,
                                items: transactionCategory.map((DropdownItem transaction) {
                                  return DropdownMenuItem(
                                    value: transaction.name,
                                    child: Row(
                                      children: [
                                        transaction.icon,
                                        SizedBox(width: 10.0,),
                                        Text(transaction.name,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValues = value.toString();
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          Row(
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
                          SizedBox(height: 20.0,),
                          SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: 24.0,
                                  )
                              ),
                              child: Text(
                                "Add Expense",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                ),
                              ),
                              onPressed: () {
                                _submitTransaction();
                                showSnackBar(context);
                                transactionTitle.clear();
                                amountInfo.clear();
                                transactionCategory.clear();
                                dropdownValues = "Select an Expense Category";
                                selectedDate = DateTime(DateTime.now().year - 1);
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
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Income/Expense Transaction", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Choose Type of Transaction:', style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),),
                  SizedBox(width: 8,),
                  DropdownButton(
                    value: isIncome,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isIncome = newValue!;
                      });
                    },
                    items: <bool>[false, true].map<DropdownMenuItem<bool>>((bool value) {
                      return DropdownMenuItem<bool>(
                        value: value,
                        child: Text(value ? "Income" : "Expense", style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16,),
              _showInputFieldsBasedOnType(isIncome)
            ],
          ),
        ),
      ),
    );
  }
}