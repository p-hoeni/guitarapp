import 'package:flutter/material.dart';
import 'package:guitar_app/models/simple_user.dart';
import 'package:guitar_app/navigation_wrapper.dart';
import 'package:guitar_app/screens/authenticate/authenticate.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<SimpleUser?>(context);

    // return either NavigationWrapper or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return NavigationWrapper();
    }
  }
}
