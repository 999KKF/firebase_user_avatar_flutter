import 'package:firebase_user_avatar_flutter/app/auth_widget.dart';
// import 'package:firebase_user_avatar_flutter/app/auth_widget_builder.dart';
import 'package:firebase_user_avatar_flutter/services/firebase_auth_service.dart';
import 'package:firebase_user_avatar_flutter/services/firebase_storage_service.dart';
import 'package:firebase_user_avatar_flutter/services/firestore_service.dart';
import 'package:firebase_user_avatar_flutter/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

typedef Materialbuilder = Widget Function(BuildContext, AsyncSnapshot<User>);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Materialbuilder builder2 =
        (BuildContext context, AsyncSnapshot<User> asynsnapshot) {
      return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: AuthWidget(userSnapshot: asynsnapshot),
      );
    };
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(),
        ),
        Provider<ImagePickerService>(
          create: (context) => ImagePickerService(),
        ),
      ],
      child: AuthWidgetBuilder(
        builder: builder2,
      ),
    );
  }
}

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);
  final Widget Function(BuildContext, AsyncSnapshot<User>) builder;

  @override
  Widget build(BuildContext context) {
    // final firebaseAuth = FirebaseAuth.instance;

    print('AuthWidgetBuilder rebuild');
    // final authService =
    //     Provider.of<FirebaseAuthService>(context, listen: false);
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.onAuthStateChanged.map<User>(
          (firebaseUser) =>
              User(uid: firebaseUser.uid)), //authService.onAuthStateChanged,
      builder: (context, asynsnapshot) {
        print('StreamBuilder: ${asynsnapshot.connectionState}');
        final User user = asynsnapshot.data;
        if (user != null) {
          return MultiProvider(
            providers: [
              Provider<User>.value(value: user),
              Provider<FirestoreService>(
                create: (_) => FirestoreService(uid: user.uid),
              ),
              Provider<FirebaseStorageService>(
                create: (_) => FirebaseStorageService(uid: user.uid),
              ),
            ],
            child: builder(context, asynsnapshot),
            // ((_, __) => MaterialApp(
            //       theme: ThemeData(primarySwatch: Colors.indigo),
            //       home: AuthWidget(userSnapshot: __),
            //     ))(_, __),
          );
        }
        return builder(context, asynsnapshot);
        // ((_, __) => MaterialApp(
        //       theme: ThemeData(primarySwatch: Colors.indigo),
        //       home: AuthWidget(userSnapshot: __),
        //     ))(_, __);
      },
    );
  }
}
