import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/home_page.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> _tabs = [
    Tab(child: Text("Phone")),
    Tab(child: Text("Email"))
  ];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: Icon(Icons.arrow_back_sharp),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Please enter your Phone or Email"),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    decoration:
                        const BoxDecoration(color: Colors.white, boxShadow: [
                      BoxShadow(
                        offset: Offset(2, 20),
                        blurRadius: 12,
                        spreadRadius: -10,
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                      )
                    ]),
                    child: TabBar(
                      tabs: _tabs,
                      controller: _tabController,
                      indicatorWeight: 6,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [PhoneTabBarView(), EmailTabBarView()],
                    ),
                  )
                ],
              )
            ]),
          ),
        ));
  }
}

class PhoneTabBarView extends StatefulWidget {
  const PhoneTabBarView({
    Key? key,
  }) : super(key: key);

  @override
  State<PhoneTabBarView> createState() => _PhoneTabBarViewState();
}

class _PhoneTabBarViewState extends State<PhoneTabBarView> {
  String? phoneno;
  String? countryCode;
  String? verificationID;

  final _pinController = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: IntlPhoneField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(),
                ),
              ),
              onChanged: (phone) {
                phoneno = phone.completeNumber;
                print(phone.completeNumber);
              },
              onCountryChanged: (country) {
                print('Country changed to: ' + country.name);
              },
            ),
          ),
          SizedBox(
            height: 60,
          ),
          if (verificationID != null) ...[
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "We've sent the code verification to your phone number",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 52,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 80,
            ),
          ],
          SizedBox(
            height: 45,
            width: 300,
            child: ElevatedButton(
                onPressed: () async {
                  if (verificationID != null) {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationID!,
                            smsCode: _pinController.text);

                    await auth.signInWithCredential(credential);
                    print("correct");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MyHomePage())); //correct
                    return;
                  }
                  await auth.verifyPhoneNumber(
                    phoneNumber: phoneno,
                    verificationCompleted: (phoneAuthCredential) async {
                      await auth.signInWithCredential(phoneAuthCredential);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyHomePage()));
                    },
                    verificationFailed: (error) {
                      print(error.message);
                    },
                    codeSent: (verificationId, forceResendingToken) {
                      verificationID = verificationId;
                      setState(() {
                        print("code sent: $verificationId");
                      });
                    },
                    codeAutoRetrievalTimeout: (verificationId) {},
                  );
                },
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)))),
                child: (verificationID == null)
                    ? Text("Send OTP",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                    : Text("Login",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          SizedBox(
            height: 30,
          ),
          if (verificationID != null) ...[
            Text(
              "By clicking Login, you accept our",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Terms & Conditions",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )
          ]
        ],
      ),
    );
  }
}

class EmailTabBarView extends StatefulWidget {
  const EmailTabBarView({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailTabBarView> createState() => _EmailTabBarViewState();
}

class _EmailTabBarViewState extends State<EmailTabBarView> {
  String? phoneNumber;
  String? countryCode;
  String? verificationId;

  final _pinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Enter Email ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60,
          ),
          if (verificationId != null) ...[
            Text(
              "Enter OTP",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "We've sent the code verification to your phone number",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 52,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(
              height: 80,
            ),
          ],
          SizedBox(
            height: 45,
            width: 300,
            child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)))),
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          ),
          SizedBox(
            height: 30,
          ),
          if (verificationId != null) ...[
            Text(
              "By clicking Login, you accept our",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Terms & Conditions",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )
          ]
        ],
      ),
    );
  }
}
