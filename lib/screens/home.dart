import 'dart:async';
import 'package:flutter/material.dart';
import "package:flare_flutter/flare_actor.dart";
import "package:flare_flutter/flare_cache_builder.dart";
import 'package:flare_flutter/provider/asset_flare.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  String _selectedAnimation = "";
  String _animationFail = "fail";
  String _animationSuccess = "success";
  String _animationIdle = "idle";
  String _loginText = "Enter";
  bool finishSuccessAnimation = false;
  bool loginSuccess = false;

  Animation<double> animation;
  bool enabled = true;




  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final asset =
      AssetFlare(bundle: rootBundle, name: "assets/login_screen_bg.flr");
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AnimationController controller;
  AnimationController checkController;

  @override
  void initState() {
    super.initState();
    loginController.text = "diogo";
    passwordController.text = "1234";
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    checkController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = CurvedAnimation(parent: checkController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controller.reverse();
            }
          });

    return Stack(
      children: <Widget>[
        Container(
          child: FlareCacheBuilder(
            [asset],
            builder: (BuildContext context, bool isWarm) {
              return !isWarm
                  ? Container(child: Text("NO"))
                  : FlareActor.asset(
                      asset,
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                      animation: _selectedAnimation,
                      callback: (name) {
                        if (name == "success"){
                          setState(() {
                            checkController.forward();
                            finishSuccessAnimation = true;
                            enabled = true;
                          });
                        }
                      },
                    );
            },
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 300,
              color:
              (_selectedAnimation == _animationFail ? Colors.transparent : Colors.white),
              child: AnimatedBuilder(
                  animation: offsetAnimation,
                  builder: (buildContext, child) {
                    if (offsetAnimation.value < 0.0)
                      print('${offsetAnimation.value + 8.0}');
                    return  Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(
                          left: offsetAnimation.value + 24.0,
                          right: 24.0 - offsetAnimation.value),
                      height: 300,
                      child: (!finishSuccessAnimation &&  !loginSuccess) ? formLogin() : FadeTransition(opacity: animation ,child: Icon(Icons.check, color: Colors.green, size: 200,),),
                    );
                  }),
            )),
      ],
    );
  }

  Widget formLogin() {
    final emailField = TextField(
      enabled: enabled,
      controller: loginController,
      obscureText: false,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Login",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextField(
      enabled: enabled,
      controller: passwordController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color.fromRGBO(33, 93, 126, 1),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          handleLogin();
        },
        child: Text(_loginText,
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(left: 36.0, right: 36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            emailField,
            SizedBox(height: 15.0),
            passwordField,
            SizedBox(
              height: 15.0,
            ),
            loginButon,
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  resetAnimation() {
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _selectedAnimation = "";
      });
    });
  }

  handleLogin() {

    setState(() {
      enabled = false;
      _loginText = "Doing login ...";
      _selectedAnimation = _animationIdle;
    });

    String nextAnimation = _animationFail;
    if (loginController.text == "diogo" && passwordController.text == "12345") {
      nextAnimation = _animationSuccess;
    }

    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _loginText = "Enter";
        if (nextAnimation == _animationFail) {
          controller.forward(from: 0.0);
        }else{
          loginSuccess = true;
        }
        _selectedAnimation = nextAnimation;
      });
      if (nextAnimation == _animationFail) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            enabled = true;
            _selectedAnimation = _animationIdle;
          });
        });
      }
    });
  }
}
