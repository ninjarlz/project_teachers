import 'package:flutter/material.dart';
import 'package:project_teachers/auth.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  bool _isLoading = false;
  String _email;
  String _password;
  bool _isLoginForm = true;
  String _errorMessage;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title : new Text("Sign in")),
      body : Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress()
        ],
      )
    );
  }

  Widget _showCircularProgress() {
      if(_isLoading) {
        return Center(child: CircularProgressIndicator());
      }
      return Container(height: 0.0, width: 0.0);
  }

  Widget _showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
        child: CircleAvatar (
          backgroundColor: Colors.transparent,
          radius: 100.0,
          child: Image.asset("assets/logo.png")
        )
      )
    );
  }

  Widget _showEmailInput(){
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 100, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          hintText: "Email",
          icon:  new Icon(Icons.mail, color: Colors.grey)
        ),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim()
      )
    );
  }

  Widget _showPasswordInput(){
    return Padding(
        padding: EdgeInsets.fromLTRB(0.0, 100, 0.0, 0.0),
        child: new TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            hintText: "Password",
            icon: new Icon(Icons.lock, color: Colors.grey)
          ),
          validator: (value) => value.isEmpty ? "Password can\'t be empty" : null,
          onSaved: (value) => _password = value.trim()
        )
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.purpleAccent,
          child: Text(
            _isLoginForm ? "Login" : "Create account",
            style: TextStyle(fontSize: 20.0, color: Colors.white)
          ),
          onPressed: _validateAndSubmit
        )
      )
    );
  }

  Widget _showSecondaryButton() {
    return FlatButton(
      child: Text(
        _isLoginForm ? "Create an account" : "Have an account? Sign in",
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)
      ),
      onPressed: _toggleFormMode,
    );
  }

  void _toggleFormMode() {
    _resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  void _validateAndSubmit() {

  }


  void _resetForm() {

  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _showForm() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showLogo(),
              _showEmailInput(),
              _showPasswordInput(),
              _showPrimaryButton(),
              _showSecondaryButton(),
              _showErrorMessage(),
            ],
          ),
        ));
  }

}