import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:proyecto_final/auth.dart';

class LoginPage extends StatefulWidget{
  
  const LoginPage ({Key? key}) : super(key: key);
  

  @override
  State<LoginPage> createState()=> _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
      try {
        await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
           password: _controllerPassword.text
           );
      } on FirebaseAuthException catch (e){
        setState(() {
          errorMessage = e.message;
        });
      }
  }

 Future<void> signInWithGoogle() async{
      try {
        await Auth().signInWithGoogle();
      }  catch (e){
        setState(() {
          errorMessage = "error $e";
        });
      }
 }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text
        );
    } on FirebaseAuthException catch (e){
        setState(() {
          errorMessage = e.message;
        });
      }
  }

    Widget _title(){
    return const Text('Firebase Auth');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ){
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage (){
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton(){
    return ElevatedButton(onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
     child: Text(isLogin ? 'Login' : 'Register')
     );
  }

  Widget _loginOrRegisterButton(){
    return TextButton(onPressed: () {
      setState(() {
        isLogin = !isLogin;
      });
    },
     child: Text (isLogin ? 'Register instead' : 'Login instead')
     );
  }
  Widget _signInWithGoogle(){
    if (isLogin){
    return Container (
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10)
      ),
      child: TextButton(onPressed: _signInWithGoogle,
     child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       Text ('Sign in with Google',
       style: TextStyle(
        color:Colors.white ),
        ),
       SizedBox(width: 5,),
       Icon(FontAwesomeIcons.google,color: Colors.white,),
     ],)
     ),
     );
    } else {
      return Container();
    } 
     
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField('email', _controllerEmail),
              _entryField('password', _controllerPassword),
              _errorMessage(),
              _submitButton(),
              _signInWithGoogle(),
              _loginOrRegisterButton(),
              
              ],
          ),
        ),
    );
  }
}