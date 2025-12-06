import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_todo_app/models/user_details.dart';
import 'package:new_todo_app/presentation/authentication/login_screen.dart';
import 'package:new_todo_app/util/firestore_collection.dart';
import 'package:new_todo_app/util/appconstant.dart';
import 'package:new_todo_app/widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  UserDetails? currentUserDetails;
  bool _isloading = false;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  final currentUser = FirebaseAuth.instance.currentUser;
  final googleSignIn = GoogleSignIn.instance;

  Future<void> fetchUserProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) _logout();

    final userProfile = await FirebaseFirestore.instance
        .collection(FirestoreCollection.userCollection)
        .doc(currentUser!.uid)
        .get();

    if (userProfile.data() == null) {
      setState(() {
        _isloading = true;
      });
      return;
    } else {
      currentUserDetails = UserDetails.fromJson(userProfile.data()!);
      firstNameController =
          TextEditingController(text: currentUserDetails?.firstName);
      lastNameController =
          TextEditingController(text: currentUserDetails?.lastName);

      setState(() {
        _isloading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    } catch (e) {
      if (!mounted) return;
      Appconstant.showSnackBar(context,
          message: "Error logging out", isSuccess: false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isloading = true;
    });

    final firestore = FirebaseFirestore.instance;
    currentUserDetails?.firstName = firstNameController.text.trim();
    currentUserDetails?.lastName = lastNameController.text.trim();

    if (currentUserDetails == null) {
      setState(() {
        _isloading = true;
      });
      return;
    } else {
      await firestore
          .collection(FirestoreCollection.userCollection)
          .doc(currentUser!.uid)
          .update(currentUserDetails!.profileNameToJson());
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  void initState() {
    fetchUserProfile();
    super.initState();
  }

  bool isSaveEnabled() {
    if (_formKey.currentState == null) return false;
    return _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isloading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : currentUserDetails == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('No details found'),
                          LogoutCta(
                            onLogout: () async => _logout(),
                          )
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // User Avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.deepPurple.shade400,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // User Email
                        Text(
                          user?.email ?? 'No email',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Welcome to TodoEasy',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 60),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: firstNameController,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "First name cannot be empty";
                                    }
                                    if (value.length < 3) {
                                      return "Name cannot be less then 3 letters";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    hintText: 'Enter Your First Name',
                                    prefixIcon: Icon(Icons.account_box_rounded),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: lastNameController,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Last name cannot be empty";
                                    }
                                    if (value.length < 3) {
                                      return "Last name cannot be less then 3 letters";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    hintText: 'Enter Your Last Name',
                                    prefixIcon: Icon(Icons.account_box_rounded),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            )),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: isSaveEnabled()
                              ? () async {
                                  await _saveProfile();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 8),
                              Text(
                                'Save',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Logout Button
                        LogoutCta(onLogout: _logout),
                        const SizedBox(height: 20),
                      ],
                    ),
        ),
      ),
    );
  }
}
