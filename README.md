# Final Project – Flutter
The final project is a chance for you to combine and practice everything you learned from this course. You will be making your own Android/iOS app using Flutter - taking it from the idea stage to building out the full app. The goal is to prototype an app related to your MEng project or another original idea as agreed by your instructor through your preliminary proposal. You are expected to be creative about how you accomplish this. Refer to the deliverables and rubric sections to have full understanding of what is required.

# Requirements
These are the technical and functional requirements for the app:
a) At least 3 different screens (not including user sign-up/login/profile screens)
b) A navigation structure using one of: BottomNavigationBar, TabBar or Drawer
c) Uses Text, Image & Icon widgets
d) Uses (from the Material design widgets) at least 1 widget for each of: Button, Input/Selection & Dialogs/Alert/Panel
e) Uses at least 4 different layout widgets; including a ListView with a builder other examples are Column, Row, Container, Center … etc
f) Uses at least 2 stateful widgets
g) App is web-enabled (either retrieving data from an actual API or a custom mock API)
h) Uses data persistence & has a non-default theme

# Bonuses
Bonus features can provide bonus marks or compensate for lost marks in other areas of the project.
a) App uses Firebase Authentication for user authentication + user profile/settings screen (in addition to the 3 main screens)
b) App uses Cloud Firestore as its backend to read/write data (replaces API requirement)
c) App uses location services or other sensors
d) App integrates Google maps (replaces location services)

# Notes:
• If using firebase as backend; show the database structure and how data is stored in your demo video as well as in screenshots
• If using Mockaroo, provide screenshot of database structure & sample data stored in it
• For other APIs provide the API endpoints used & an example of the response
• Make sure you are using the latest version of Flutter to create your app as well as the latest versions of any packages used

# Expense-Tracker-Mobile-Application

I have built an Expense Tracker & Budget planner mobile application using Flutter. The functionality of the application are as follows,

# Sign Up/Sign In Screen: This uses Firebase User Authentication and Authorization. The user has to provide email Id and password

![signUpScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/571430fa-9ff5-4360-810b-a8b767078a05)
![signInScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/37c59c22-5a2e-49f6-a39f-fb1e0d0ad0ce)

# Dashboard: Overview of recent transactions, existing balance.

![dashboard](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/0ff5c474-44fe-452e-9361-7b487d39d6e9)

# Analytics Screen: A graphical representation of expenses for the entire month.

![analyticsScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/bee2a231-4660-4c7b-99f0-511bd5b9ed16)

# Goals Screen: Track and manage savings goals.

![goalsScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/c76af110-b80f-400d-9e58-050eb54bac5c)
![addGoals](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/3d81daf6-24f1-494d-a819-1237a7fe05c1)

# User Profile Screen: Manage Display Name, Profile picture, Phone Number information

![userProfileScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/6997d595-f3b0-4fa1-a321-99b85473da78)
![editProfileScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/c0f53551-aae5-40a7-8072-cebde7b644e1)
![deleteUserAccountScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/efd8673b-1d26-4964-a206-a3931f3abda3)

# ‘+’ button on the Home screen i.e Dashboard navigates the user to Add Expenses/ Income screen where based on the user selection the input fields dynamically changes depending on Income/Expenses.

![addExpenseScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/6674b99a-1486-4af2-b75d-09aa136e3958)
![addIncomeScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/fd61c24a-6e81-4164-ba69-4a34912bd63d)


# Transaction Details Screen: On clicking each of the Dashboard recent transactions the user will be navigated to Transaction Details screen where the user will be able to edit or delete the transaction.

![transactionDetailScreen](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/ce2b2a3d-066f-4e7f-958e-6be95f5d1d8b)
![editExpense](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/e89ddcb2-cd05-43ac-bd9b-1d17b5932122)
![editIncome](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/93d7fd8a-1f88-4028-bb4b-d984d23e6fca)
![deleteTransaction](https://github.com/Sumanth-Mahabaleshwar-Bhat/expense_tracker/assets/120843537/ba5a304a-dc5f-4c4f-9929-3e85c2d07c21)

# For Web-enablement: I am using Firebase REST API for real-time database access and save user generated data with Firebase.

# For storing profile images, I am using Storage in Firebase

# Firebase Authentication
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/fa467e4a-9a9a-4fc5-885e-f2b68762381d)

# Cloud Firestore (Database storage & REST API)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/43b4ee24-49ed-4f9f-91ef-f1f53883c509)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/2bd82eae-8292-47b2-937e-b986ee1e11ff)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/fa86219f-f1d3-4f51-9c46-75d150125285)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/c33168a7-7e27-4178-bd47-7bd21c8b7a88)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/3688e987-4184-43ff-a87b-59cbfa0114f5)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/1fbaced2-1a9f-4806-9a73-6585998959c5)

# Storage (for storing profile images)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/327ce9a9-1511-4b8c-9d06-3cdf0bf56582)
![image](https://github.com/Sumanth-Mahabaleshwar-Bhat/Expense-Tracker-Mobile-Application/assets/120843537/7abd8a14-28f8-485d-ba33-0c9f69e86f2e)



