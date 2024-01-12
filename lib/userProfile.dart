import 'dart:typed_data';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:path/path.dart';

import 'auth_gate.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  DocumentSnapshot<Map<String, dynamic>>? _userData;
  late User? _currentUser;
  var imageUrl;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserDatafromFirebase();
    _getImageFromFirebaseStorage().then((url) {
      setState(() {
        imageUrl = url;
      });
    });
  }

  void _fetchUserDatafromFirebase() async {
    final _currentUser = this._currentUser;
    if (_currentUser != null) {
      var userDocRef =
      FirebaseFirestore.instance.collection('expenseTrackerUsers').doc(_currentUser.uid).collection('users').doc(_currentUser.uid);

      var snapshot = await userDocRef.get();

      if (!snapshot.exists) {
        await userDocRef.set({
          'displayName': _currentUser.displayName ?? '',
          'email': _currentUser.email ?? '',
          'phoneNumber': '',
        });
      }

      setState(() {
        _userData = snapshot;
      });
    }
  }

  Future<void> _sendVerificationEmail() async {
    if(_currentUser != null && !_currentUser!.emailVerified) {
      await _currentUser!.sendEmailVerification();
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if(_currentUser != null) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete User Pop-up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
              content: Text('Are you sure you want to delete the user account ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
              actions: [
                ElevatedButton.icon(
                  onPressed: () {
                    _currentUser!.delete();
                    Navigator.pop(context);
                    AuthGate();
                    },
                  icon: Icon(Icons.delete),
                  label: Text('Delete User Account'),
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

  Future<void> _saveUserProfileChanges(String? newDisplayName, String? newPhoneNumber, String? imageUrl) async {
    try {
      final _currentUser = this._currentUser;
      if (_currentUser != null) {
        await FirebaseFirestore.instance.collection('expenseTrackerUsers').doc(_currentUser.uid).collection('users').doc(_currentUser.uid).update({
          'displayName': newDisplayName,
          'phoneNumber': newPhoneNumber,
          'profileImageUrl': imageUrl, // Use the imageUrl directly
        });

        _fetchUserDatafromFirebase();
      }
    } catch (error) {
      print('Error saving profile changes: $error');
    }
  }


  void _editUserProfile(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return EditUserProfileModal(
            currentDisplayName: _userData?['displayName'],
            currentPhoneNumber: _userData?['phoneNumber'],
            onSave:(String? newDisplayName, String? newPhoneNumber, String? image_Url) {
              _saveUserProfileChanges(newDisplayName, newPhoneNumber, image_Url);
              Navigator.pop(context);
            }
          );
        }
    );
  }

  Future<String> _getImageFromFirebaseStorage() async {
    try {
      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('profile_images/${_currentUser!.uid}');
      return await ref.getDownloadURL();
    } catch (error) {
      print('Error fetching User profile image: $error');
      // Return the URL of your placeholder image stored in Firebase Storage
      final firebase_storage.Reference placeholderRef =
      firebase_storage.FirebaseStorage.instance.ref().child('placeholderImage/userplaceholder.png');
      return await placeholderRef.getDownloadURL();
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
        ),
        body: Center(
          child: CircularProgressIndicator(), // or any other loading indicator
        ),
      );
    }

    if (!_userData!.exists) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User Profile'),
        ),
        body: Center(
          child: Text('User profile not found.'),
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

    return FutureBuilder<String?>(
      future: _getImageFromFirebaseStorage(),
      builder: (context, imageSnapshot) {
        if(imageSnapshot.connectionState == ConnectionState.done &&
            !imageSnapshot.hasError &&
            imageSnapshot.data != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text("User Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),),
              backgroundColor: Colors.indigo.shade100,
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
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(imageSnapshot.data!), // Replace with your placeholder image
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8.0),
                        Text(
                          'Display Name : ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          _userData!['displayName'] ?? '',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined),
                        SizedBox(width: 8.0),
                        Text(
                          'User Email : ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          _currentUser!.email ?? '',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 8.0),
                        Text(
                            'Phone Number : ',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            _userData!['phoneNumber'] ?? '',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _editUserProfile(context);
                      },
                      label: Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(Icons.edit),
                    ),
                    ElevatedButton.icon(
                      onPressed: _sendVerificationEmail,
                      label: Text(
                        "Send Verification Email",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      icon: Icon(Icons.email_outlined),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _deleteAccount(context);
                      },
                      label: Text(
                        "Delete User Account",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red.shade100),
                      ),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
      },
    );
  }
}

class EditUserProfileModal extends StatefulWidget {
  final String? currentDisplayName;
  final String? currentPhoneNumber;
  final Function(String?, String?, String?) onSave;

  EditUserProfileModal({
    required this.currentDisplayName,
    required this.currentPhoneNumber,
    required this.onSave,
  });

  @override
  _EditProfileModalState createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditUserProfileModal> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _userProfileImage;
  var _currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.currentDisplayName ?? '';
    _phoneNumberController.text = widget.currentPhoneNumber ?? '';
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _userProfileImage = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _userProfileImage = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_userProfileImage == null) return;
    final fileName = basename(_userProfileImage!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_userProfileImage!);
    } catch (error) {
      Text('Error in uploading the image: $error');
    }
  }

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _userProfileImage = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage() async {
    try {
      if (_userProfileImage != null) {
        final firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref('profile_images/${_currentUser!.uid}');
        final firebase_storage.UploadTask uploadTask = ref.putFile(_userProfileImage!);

        await uploadTask;

        // Get the download URL from the uploaded file
        final String downloadURL = await ref.getDownloadURL();
        return downloadURL;
      }
    } catch (error) {
      print('Error Uploading the image: $error');
      return null;
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: [
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text('Gallery'),
                    onTap: () {
                      imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _userProfileImage != null ? FileImage(_userProfileImage!) : null,
                ),
              ),
            ),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'Display Name'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    String? imageUrl = await _uploadImage();
                    widget.onSave(
                      _displayNameController.text.trim(),
                      _phoneNumberController.text.trim(),
                      imageUrl, // Pass the imageUrl directly
                    );
                    UserProfile();
                  },
                  label: Text('Save Changes'),
                  icon: Icon(Icons.save_outlined),
                ),
                SizedBox(width: 10.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: Text('Cancel'),
                  icon: Icon(Icons.cancel_outlined),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}