import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:amigos_hackalearn/model/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import '../widget/input_field.dart';

class PostScreen extends StatefulWidget {
  final String uid;
  const PostScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _postTitlecontroller = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _image;
  var _isLoading = false;
  late final model.User user;
  void setUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      user = model.User.fromSnap(userSnap);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setUser();
  }

  Future<void> _sendPost(
      {required String postTitle,
      required DateTime dateTime,
      required String content,
      required Uint8List file,
      required String author,
      required String uid,
      required int saved,
      required String profileImg}) async {
    late String res;
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('postImages').child('1');
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String photoUrl = await snapshot.ref.getDownloadURL();
      Post post = Post(
          id: '1',
          author: author,
          postTitle: postTitle,
          dateTime: dateTime,
          content: content,
          photoUrl: photoUrl,
          uid: user.uid,
          saved: saved,
          profileImg: profileImg);
      firestore.collection('posts').doc().set(post.toJson());
      res = "success";
    } catch (e) {
      res = e.toString();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error ocurred.'),
          content: Text('오류가 발생했습니다.'),
          actions: <Widget>[
            FlatButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              // 프로필 이미지 선택 UI
              _image != null
                  ? Image(
                      image: MemoryImage(_image!),
                      width: 150,
                      height: 150,
                    )
                  : const Image(
                      image: AssetImage('assets/dark_logo.png'),
                      width: 150,
                      height: 150,
                    ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  // 이미지 선택 기능
                  onPressed: () async {
                    Uint8List img = await pickImage(ImageSource.gallery);
                    setState(() {
                      _image = img;
                    });
                  },
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text('글 제목'),
              InputField(
                  textEditingController: _postTitlecontroller,
                  hintText: "글 제목을 입력해주세요",
                  inputType: TextInputType.text),
            ],
          ),
          //본문 입력
          Column(
            children: [
              Text('본문 내용'),
              InputField(
                  textEditingController: _contentController,
                  hintText: "내용을 입력해주세요",
                  inputType: TextInputType.text),
            ],
          ),

          Column(
            children: [
              Text('아낀 금액'),
              InputField(
                  textEditingController: _priceController,
                  hintText: "금액을 입력해주세요",
                  inputType: TextInputType.number),
            ],
          ),
          InkWell(
              child: Container(
                padding: EdgeInsets.all(12.0),
                child: Text('Flat Button'),
              ),
              onTap: () {
                final int _saved = int.parse(_priceController.text);
                final dateTime = DateTime.now();
                final FirebaseStorage storage = FirebaseStorage.instance;
                //user정보 확인
                print(user.username);

                _sendPost(
                    postTitle: _postTitlecontroller.text,
                    dateTime: dateTime,
                    content: _contentController.text,
                    file: _image!,
                    author: user.username,
                    uid: user.uid,
                    saved: _saved,
                    profileImg: user.photoUrl);
              }),
        ],
      ),
    );
  }
}
