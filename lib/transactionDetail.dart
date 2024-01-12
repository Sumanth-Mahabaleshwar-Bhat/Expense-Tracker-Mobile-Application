import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';

class DropdownItem {
  const DropdownItem(this.name, this.icon);
  final String name;
  final Icon icon;
}

class Transaction {
  final String transactionId;
  final String transactionTitle;
  final double transactionAmount;
  late final String transactionCategory;
  final DateTime transactionDate;

  Transaction({
    required this.transactionId,
    required this.transactionTitle,
    required this.transactionAmount,
    required this.transactionCategory,
    required this.transactionDate,
  });
}

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({required this.transaction});

  @override
  _TransactionDetailScreenState createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TextEditingController titleController = new TextEditingController();
  late TextEditingController amountController = new TextEditingController();
  late TextEditingController dateController = new TextEditingController();

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

  String dropdownValues = 'None';

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetailsFromFirebase();
  }

  Future<void> _fetchTransactionDetailsFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot transactionSnapshot = await FirebaseFirestore.instance
            .collection('expenseTrackerUsers')
            .doc(currentUser.uid)
            .collection('transactions')
            .doc(widget.transaction.transactionId)  // Use the correct document reference
            .get();

        if(transactionSnapshot.exists) {
          Map<String, dynamic> transactionData = transactionSnapshot.data() as Map<String, dynamic>;
          titleController = TextEditingController(text: transactionData['transactionTitle']);
          amountController = TextEditingController(text: transactionData['transactionAmount'].toString());
          dropdownValues = transactionData['transactionCategory'];
          dateController = TextEditingController(
              text: (transactionData['transactionDate'] as Timestamp).toDate().toString().split(' ')[0]);
        }
      }
    } catch (error) {
      Text('Error fetching transaction details: $error'); // Use print instead of Text
    }
  }

  Future<void> _saveTransactionChanges(
      String newTitle,
      double newAmount,
      String newCategory,
      DateTime newDate,
      ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('expenseTrackerUsers')
            .doc(currentUser.uid)
            .collection('transactions')
            .doc(widget.transaction.transactionId)  // Use the correct document reference
            .update({
          'transactionTitle': newTitle,
          'transactionAmount': newAmount,
          'transactionCategory': newCategory,
          'transactionDate': newDate,
        });

        Navigator.pop(context);

      }
    } catch (error) {
      Text('Error updating transaction details: $error');
    }
  }

  Future<void> _deleteTransactionChanges(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Transactions Pop-up',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),),
              content: Text('Are you sure you want to delete the transaction ?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),),
              actions: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('expenseTrackerUsers')
                        .doc(currentUser.uid).collection('transactions')
                        .doc(widget.transaction.transactionId).delete();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.delete),
                  label: Text('Delete Transaction'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel),
                  label: Text('Cancel'),
                )
              ],
            );
          });
    }
  }

  void _editTransaction(BuildContext context) {
    titleController.text = widget.transaction.transactionTitle;
    amountController.text = (widget.transaction.transactionAmount < 0 ? (-1) * widget.transaction.transactionAmount : widget.transaction.transactionAmount).toString();
    dateController.text = widget.transaction.transactionDate.toLocal().toString().split(' ')[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton(
                      iconSize: 25.0,
                      hint: Text("Select category of Transaction"),
                      isExpanded: true,
                      value: widget.transaction.transactionCategory == 'Income' ? 'None' : widget.transaction.transactionCategory,
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
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: widget.transaction.transactionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null && pickedDate != widget.transaction.transactionDate) {
                        setState(() {
                          dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          _saveTransactionChanges(
                            titleController.text,
                            dropdownValues != 'Income' ? (-1) * double.parse(amountController.text) : double.parse(amountController.text),
                            dropdownValues == 'None' ? widget.transaction.transactionCategory : dropdownValues,
                            DateTime.parse(dateController.text),
                          );
                        },
                        child: Text('Save Changes'),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel')
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction Details",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: widget.transaction.transactionCategory == 'Income' ? Image.asset('assets/images/income.png', height: 200.0,) : Image.asset('assets/images/expense.png', height: 200.0,),
              ),
              Card(
                color: widget.transaction.transactionCategory == 'Income' ? Colors.green : Colors.redAccent,
                elevation: 3,
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text('Title: ${widget.transaction.transactionTitle}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Amount: ${widget.transaction.transactionAmount < 0 ? (-1) * widget.transaction.transactionAmount : widget.transaction.transactionAmount}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),),
                      Text('Transaction Category: ${widget.transaction.transactionCategory}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),),
                      Text('Transaction Date: ${widget.transaction.transactionDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                          ),)
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40.0,),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit,),
                      label: Text('Edit Transaction Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )),
                      onPressed: () {
                        _editTransaction(context);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete,),
                      label: Text('Delete Transaction',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),),
                      onPressed: () async {
                        await _deleteTransactionChanges(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}