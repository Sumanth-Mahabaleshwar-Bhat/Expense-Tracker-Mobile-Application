import 'package:expense_tracker/goals.dart';
import 'package:expense_tracker/userProfile.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'add_transaction.dart';
import 'analytics.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget  {
  const HomeScreen({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int currentTab = 0;
  bool isFabVisible = true;
  final List<Widget> screens = [
    const Dashboard(),
    const Add_Transaction(),
    const Analytics(),
    const GoalsScreen(),
    const UserProfile(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),
      floatingActionButton: isFabVisible ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          setState(() {
            currentScreen = Add_Transaction();
            currentTab = -1;
            isFabVisible = false;
          });
        },
        backgroundColor: Colors.red,
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 12,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          currentScreen = Dashboard();
                          currentTab = 0;
                          isFabVisible = true;
                        });
                      },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined,
                        color: currentTab == 0 ? Colors.lightBlue : Colors.grey,
                        ),
                        Text("Home")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        currentScreen = Analytics();
                        currentTab = 1;
                        isFabVisible = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_outlined,
                          color: currentTab == 1 ? Colors.lightBlue : Colors.grey,
                        ),
                        Text("Analytics")
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        currentScreen = GoalsScreen();
                        currentTab = 2;
                        isFabVisible = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card,
                          color: currentTab == 2 ? Colors.lightBlue : Colors.grey,
                        ),
                        Text("Goals")
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        currentScreen = UserProfile();
                        currentTab = 3;
                        isFabVisible = false;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person,
                          color: currentTab == 3 ? Colors.lightBlue : Colors.grey,
                        ),
                        Text("Profile")
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}