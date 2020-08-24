import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  String profilePlaceHolder = "https://firebasestorage.googleapis.com/v0/b/twelve-ccbd2.appspot.com/o/static%2Fuser.png?alt=media&token=9b70d60d-fbad-4f77-9847-6c97214ba509";
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  Firestore _db = Firestore.instance;
  DocumentReference currentUser;
  StorageReference storageReference;
  File imageFile;
  String photoUrl;
  FirebaseUser _user;
  String userName;
  String userEmail;
  String userMobile;
  String _uploadUrl;
  bool updated = false;
  GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  GlobalKey<FormState> _mobileKey = GlobalKey<FormState>();
  GlobalKey<FormState> _pinKey = GlobalKey<FormState>();
  GlobalKey<FormState> _stateKey = GlobalKey<FormState>();
  GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  void getUser()async{
    FirebaseUser user= await FirebaseAuth.instance.currentUser().then((value){
    setState(() {
      _user = value; 
      photoUrl = value.photoUrl; 
      userName = value.displayName;
      userEmail = value.email;
    });
   });
  }
  void getUserAdditionalInfo()async{
    _db.collection('user')
    .where('id',isEqualTo:_user.uid)
    .getDocuments()
    .then((value){
      setState(() {
        userMobile = value.documents[0].data['phone'];
      });
    });
  }
  Future getImage()async{
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    File cropped = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1,ratioY: 1),
      compressQuality: 100,
      maxHeight: 200,
      maxWidth: 200,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: Colors.black87,
        toolbarTitle: "Cropper",
        statusBarColor: Colors.redAccent,
        backgroundColor: Colors.white
      ));
    setState(() {
      imageFile = cropped;
      updated =true;
    });
    storageReference = FirebaseStorage.instance.ref()
    .child('users/${Path.basename(imageFile.path)}');
    StorageUploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask.onComplete;
    Fluttertoast.showToast(msg: "Image Updated");
    storageReference.getDownloadURL().then((value){
      setState(() {
        _uploadUrl = value;
      }); 
    });
   }
  @override
  void initState() {
    getUser();
    getUserAdditionalInfo();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                height: 316,
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                         child: Padding(
                          padding: EdgeInsets.only(left: 20.0, top: 20.0),
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 25.0),
                                child: new Text('PROFILE',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        fontFamily: 'sans-serif-light',
                                        color: Colors.black)),
                              )
                            ],
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                                width: 250,
                                height: 250,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 125,
                                  backgroundImage: updated?FileImage(imageFile):NetworkImage(photoUrl??profilePlaceHolder)
                                ),
                                ),
                          ],
                        ),
                        Visibility(
                          visible: !_status,
                            child: Positioned(
                             top: 70,
                             left: 305,
                              child: GestureDetector(
                                onTap: (){
                                  showDialog(context: context,builder: (BuildContext context){
                                    return AlertDialog(
                                     content: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         ListTile(
                                           leading: Icon(Icons.delete),
                                           title: Text("Clear Image"),
                                           onTap: () {
                                             setState(() {
                                               photoUrl = null;
                                              updated =false;
                                             });
                                             Navigator.of(context).pop();
                                           },
                                         ),
                                         ListTile(
                                           leading: Icon(Icons.photo),
                                           title: Text("Pick From Gallery"),
                                           onTap: (){
                                             getImage();
                                               Navigator.of(context).pop();
                                           },
                                         ),
                                       ],
                                     ),
                                    );
                                  });
                                },
                                 child: Padding(
                                  padding: EdgeInsets.only(top: 90.0, right: 100.0),
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new CircleAvatar(
                                        backgroundColor: Colors.red[700],
                                        radius: 15.0,
                                        child: new Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      )
                                    ],
                                  )),
                              ),
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
              new Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    'Parsonal Information',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _status ? _getEditIcon() : new Container(),
                                ],
                              )
                            ],
                          )),
                          !(userName==null||userName==""||!_status)
                          ?Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    userName,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ))
                        :Padding(
                            padding: EdgeInsets.only(
                                left: 25.0, right: 25.0, top: 2.0),
                            child: new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Flexible(
                                  child: Form(
                                    key: _nameKey,
                                     child: new TextFormField(
                                       validator: (input){
                                         if(input.isEmpty){
                                           return "Provide Name";
                                         }
                                       },
                                       onSaved: (input)=> userName = input,
                                      decoration: const InputDecoration(
                                        hintText: "Enter Your Name"
                                      ),
                                      enabled: !_status,
                                      autofocus: !_status,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      !(_user.email==null||_user.email==''||!_status)?
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                    _user.email,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ))
                      :Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                child: Form(
                                  key: _emailKey,
                                  child: new TextFormField(
                                    validator: (input){
                                      if(!input.contains(RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'))){
                                            return "Enter Valid ";
                                          }
                                         },
                                         onSaved: (input)=>userEmail = input,
                                    decoration: const InputDecoration(
                                        hintText: "email"),
                                    enabled: !_status,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      !(userMobile!=null||userMobile!=''||!_status)?
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  new Text(
                                     userMobile,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ))
                      :Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              new Flexible(
                                key: _mobileKey,
                                child: Form(
                                 child: new TextFormField(
                                   validator: (input){
                                     if(input.length!=10){
                                       return "Enter Valid Number";
                                     }
                                   },
                                   onSaved: (input)=> userMobile = input,
                                    decoration: const InputDecoration(
                                        hintText: "Enter Mobile Number"),
                                    enabled: !_status,
                                  ),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'Pin Code',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                              Expanded(
                                child: Container(
                                  child: new Text(
                                    'State',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: new Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: new TextField(
                                    decoration: const InputDecoration(
                                        hintText: "Enter Pin Code"),
                                    enabled: !_status,
                                  ),
                                ),
                                flex: 2,
                              ),
                              Flexible(
                                child: new TextField(
                                  decoration: const InputDecoration(
                                      hintText: "Enter State"),
                                  enabled: !_status,
                                ),
                                flex: 2,
                              ),
                            ],
                          )),
                      !_status ? _getActionButtons() : new Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ));
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                    if(_nameKey.currentState.validate()&&_emailKey.currentState.validate()){
                      _nameKey.currentState.save();
                      _emailKey.currentState.save();
                      _mobileKey.currentState.save();
                      UserUpdateInfo update = UserUpdateInfo();
                        update.photoUrl =_uploadUrl;
                        update.displayName = userName;
                          _user.updateProfile(update);
                        Firestore.instance.document("users/${_user.uid}").updateData({
                          "dp":_uploadUrl,
                          "username": userName,
                          "email": userEmail,
                          "phone": userMobile,
                          });
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                    }
                  },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )
            ),
          ),flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: new Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}