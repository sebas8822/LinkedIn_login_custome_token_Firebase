import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  runApp(MyApp());
}

Future<void> initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Firebase initialized successfully');
}

final String client_id = '86huxyar2l3rkb';
final String client_secret = 'Cx9cLaatuW5huwQf';
final String redirect_uri = 'http://localhost:52138/auth.html';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login with Linkedin into Firebase'),
        ),
        body: AuthScreen(),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String _status = '';
  String _pictureUrl = '';
  String _firstName = '';
  String _lastName = '';
  String _emailAddress = '';
  String _userId = '';

  void showProfilePicture() {
    if (_pictureUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Profile Picture'),
            content: Image.network(_pictureUrl),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> authenticate() async {
    setState(() {
      _status = 'Authenticating...';
    });

    Future<String?> handleAuthResultCode(String result) async {
      final currentUri = Uri.parse(result);

      if (currentUri.queryParameters.containsKey('code')) {
        final code = currentUri.queryParameters['code'];
        return code;
      }

      return null;
    }

    Future<String> getPicture(String accessToken) async {
      final url = Uri.parse(
          'https://api.linkedin.com/v2/me?projection=(profilePicture(displayImage~:playableStreams))');
      final headers = {'Authorization': 'Bearer $accessToken'};

      try {
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final profilePic = jsonResponse['profilePicture']['displayImage~']
              ['elements'][0]['identifiers'][0]['identifier'];

          return profilePic.toString();
        } else {
          print('Request failed with status: ${response.statusCode}');
          return '${response.statusCode}';
        }
      } catch (e) {
        print('Error getPicture: $e');
        return '$e';
      }
    }

    Future<String> getEmailAddress(String accessToken) async {
      final url = Uri.parse(
          'https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))');
      final headers = {'Authorization': 'Bearer $accessToken'};

      try {
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final email = jsonResponse['elements'][0]['handle~']['emailAddress'];
          return email.toString();
        } else {
          print('Request failed with status: ${response.statusCode}');
          return '${response.statusCode}';
        }
      } catch (e) {
        print('Error getEmailAddress: $e');
        return '$e';
      }
    }

    Future<void> getProfile(String accessToken) async {
      final url = Uri.parse('https://api.linkedin.com/v2/me');
      final headers = {'Authorization': 'Bearer $accessToken'};

      try {
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final pictureURL = await getPicture(accessToken);
          final firstName = jsonResponse['firstName']['localized']['es_ES'];
          final lastName = jsonResponse['lastName']['localized']['es_ES'];
          final userId = jsonResponse['id'];
          final email = await getEmailAddress(accessToken);

          setState(() {
            _firstName = firstName;
            _lastName = lastName;
            _pictureUrl = pictureURL;
            _emailAddress = email;
            _userId = userId;
            _status =
                "Get Profile and UserID is used as Id to save it into Firebase";
          });
          await signinCustomUserFirebase(
              userId, email, pictureURL, firstName, lastName);
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error getProfile: $e');
      }
    }

    Future<void> requestAccessToken(String code) async {
      final url = Uri.parse('https://www.linkedin.com/oauth/v2/accessToken');
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      final body = {
        'grant_type': 'authorization_code',
        'client_id': client_id,
        'client_secret': client_secret,
        'code': code,
        'redirect_uri': redirect_uri,
      };

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final accessToken = jsonResponse['access_token'];

          await getProfile(accessToken);
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Error requestAccessToken: $e');
      }
    }

    print('Authenticating...');

    final url = 'https://www.linkedin.com/oauth/v2/authorization?'
        'response_type=code&'
        'client_id=$client_id&'
        'redirect_uri=$redirect_uri&'
        'scope=r_liteprofile%20r_emailaddress';

    final result = await FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: 'http',
    );

    final code = await handleAuthResultCode(result);

    if (code != null) {
      await requestAccessToken(code);
    }
  }

  // Fuction that autenticate custom Provider (Linkedin, seek, Indeed)

  Future<void> signinCustomUserFirebase(
      userId, String email, String pictureURL, firstName, lastName) async {
    //Generate custom user
    final customToken = await generateCustomToken(userId);
    setState(() {
      _status = "CustomeToken Generated";
    });

    final signinfirebase = await signInWithCustomToken(customToken as String);
    setState(() {
      _status = "signIn With a Custom Token";
    });

    if (signinfirebase) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        print('signInWithCustomToken - userID: $uid'); // Is it same?
        if (userId == uid) {
          setState(() {
            _status = "Checking if user Exists in the firebase ...... ";
          });
          // Check if the user exists in the database
          bool userExists = await checkCustomUserExists(uid);

          if (userExists) {
            // User exists in the database,
            print('User exists in the database');
            setState(() {
              _status = "User already exits ...... ";
            });
          } else {
            // User doesn't exist in the database, create a new user, save data, and perform login
            print('User does not exist in the database');
            setState(() {
              _status = "User Does not exits ...... ";
            });
            //Save data of user in database
            await createCustomUser(uid, email, pictureURL, firstName, lastName);
            setState(() {
              _status = "User Created!!";
            });
          }
        } else {
          print("Authentication Failed - something went wrong");
          // Authentication failed
        }
      }
    }
  }

  // It is require to enable IAM Service Account Credentials API
  // in cloud console Creates short-lived credentials
  // for impersonating IAM service accounts
  // http request with userID in this case linkedin ID user
  // Finally get response with a custome token, this allow to sign in
  // new client who is intending sign in in our app

  Future<String?> generateCustomToken(String userID) async {
    try {
      await initializeFirebase();
      print("generateCustomToken - Init App Firebase");

      final url = Uri.parse(
          'https://us-central1-jsninja-dev.cloudfunctions.net/custom-token?userID=$userID');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final customToken = response.body;
        print('Custom Token: $customToken');
        return customToken;
      } else {
        print(
            'Failed to fetch custom token. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Failed to authenticate user: $e');
      return null;
    }
  }

  // After generate a custom token is require verify if the customer already
  // exists in our database and finish login therwise is created, save data
  // and login to the app
  Future<bool> signInWithCustomToken(String customToken) async {
    print('signInWithCustomToken');
    try {
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      print('signInWithCustomToken -- no error yet');
      return true;
    } catch (e) {
      print('Authentication with custom token Error: $e');
      return false;
    }
  }

  // Save the user data based
  Future<void> createCustomUser(String uid, String email, String pictureURL,
      String firstName, String lastName) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(uid);

      await userRef.set({
        'email': email,
        'pictureURL': pictureURL,
        'firstName': firstName,
        'lastName': lastName,
      });

      print('User created with UID: $uid');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future<bool> checkCustomUserExists(String uid) async {
    try {
      final DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('user').doc(uid).get();
      return snapshot.exists; //true
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_pictureUrl.isNotEmpty) Image.network(_pictureUrl),
          Text('First Name: $_firstName'),
          Text('Last Name: $_lastName'),
          Text('Email Address: $_emailAddress'),
          Text('UserId: $_userId'),
          Text('Status: $_status'),
          const SizedBox(height: 80),
          TextButton.icon(
            onPressed: authenticate,
            icon: Image.asset(
              'assests/Sign-In-Large---Hover.png',
              width: 180,
              height: 50,
            ),
            label: const Text(''),
          ),
        ],
      ),
    );
  }
}
