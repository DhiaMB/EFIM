import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:p001/services/auth/auth_service.dart';
import '../../constants/router.dart';
import '../../enums/menu_action.dart';
import '../../services/crud/database.dart';

class InvatoryView extends StatefulWidget {
  const InvatoryView({super.key});

  @override
  State<InvatoryView> createState() => _InvatoryViewState();
}

class _InvatoryViewState extends State<InvatoryView> {
  late final DbService _dbService;

  //get user email
  String get userEmail => AuthService.firebase().currentUser!.email!;
  String get userID => AuthService.firebase().currentUser!.id;
  String userName = "salah";
  @override
  void initState() {
    _dbService = DbService();
    super.initState();
// Initialize DbService instance
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invatory Page '),
        backgroundColor: Colors.cyan,
        // action : [] is a list of widgets
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NewInvatoryViewRote);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    // logout from firebase
                    await AuthService.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _dbService.getOrCreatUser(
            name: userName, id: userID, adress: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _dbService.allDepartments,
                builder: (context, departmentSnapshot) {
                  switch (departmentSnapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('Waiting...');
                    case ConnectionState.active:
                      if (departmentSnapshot.hasData) {
                        final allDepartments =
                            departmentSnapshot.data as List<DepartmentModel>;
                        return ListView.builder(
                          itemCount: allDepartments.length,
                          itemBuilder: (context, index) {
                            final department = allDepartments[index];
                            return ListTile(
                              title: Text(department.departementName),
                              subtitle: Text('ID: ${department.departementID}'),
                              // Add other relevant information here
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );

            // return StreamBuilder(
            //   stream: _dbService.allDepartments,
            //   builder: (context, snapshot) {
            //     switch (snapshot.connectionState) {
            //       case ConnectionState.waiting:
            //         return const Text('Waiting..');
            //       case ConnectionState.active:
            //         if (snapshot.hasData) {
            //           final allDepartments =
            //               snapshot.data as List<DataBaseDepartement>;
            //           return ListView.builder(
            //               itemCount: allDepartments.length,
            //               itemBuilder: (context, index) {
            //                 return const Text('item');
            //               });
            //         } else {
            //           return const CircularProgressIndicator();
            //         }

            //       default:
            //         return const CircularProgressIndicator();
            //     }
            //   },
            // );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure '),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Sing out'),
          )
        ],
      );
    },
// showDialog<bool> should return a bool :D but in this case i'm return'in optional bool wish leads to an error!
//to fix it we append then function saying that 'if showDialog<> isn't abel to reutrn a boolean
// then im going to return false other wise return the value of the showDialog
  ).then((value) => value ?? false);
}
