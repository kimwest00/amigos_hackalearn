import 'package:amigos_hackalearn/model/post.dart';
import 'package:amigos_hackalearn/model/user.dart' as model;
import 'package:amigos_hackalearn/screen/detail_screen.dart';
import 'package:amigos_hackalearn/screen/login_screen.dart';
import 'package:amigos_hackalearn/screen/profile_edit_screen.dart';
import 'package:amigos_hackalearn/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widget/add_post_button.dart';

class MyPageScreen extends StatefulWidget {
  final String uid;
  const MyPageScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late model.User user;
  bool isLoading = false;

  void setUser() async {
    setState(() {
      isLoading = true;
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
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setUser();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: whiteColor,
            appBar: AppBar(
              elevation: 0,
              title: const Text(
                '마이페이지',
                style: TextStyle(color: primaryColor),
              ),
              backgroundColor: whiteColor,
              centerTitle: false,
            ),
            body: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Column(children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoUrl),
                                  backgroundColor: ButtonColor,
                                  radius: 50,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ]),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    user.username,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    '님이 지금까지',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              //총 아낀 금액 카드
                              height: 100,
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: whiteColor,
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromARGB(255, 226, 224, 224),
                                ),
                              ),

                              child: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      '💰',
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    Text(
                                      '총 아낀 금액',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    ),
                                    Text(
                                      ' ${(snapshot.data! as dynamic)['saved'].toString()}  원',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // 총 절약 일수 카드
                            Container(
                              height: 100,
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: whiteColor,
                                border: Border.all(
                                  width: 1,
                                  color: Color.fromARGB(255, 226, 224, 224),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '🗓️',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  Text(
                                    '${(snapshot.data! as dynamic)['implements'].length.toString()} 일 째',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '절약 실천중',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Spacer(
                                  flex: 1,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: const BorderSide(
                                                  color: primaryColor)))),
                                  onPressed: () async {
                                    if (!mounted) return;
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProfileEditScreen(user: user),
                                      ),
                                    );

                                    setUser();
                                  },
                                  child: const Text(
                                    '프로필 편집',
                                    style: TextStyle(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: const BorderSide(
                                                  color: primaryColor)))),
                                  onPressed: () async {
                                    FirebaseAuth auth = FirebaseAuth.instance;
                                    await auth.signOut();
                                    if (!mounted) return;
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '로그아웃',
                                    style: TextStyle(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    user.username,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(8),
                                  child: const Text(
                                    '님의 절약 기록',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .where('uid', isEqualTo: widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            itemCount: (snapshot.data! as dynamic).docs.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 1.5,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              DocumentSnapshot snap =
                                  (snapshot.data! as dynamic).docs[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                          post: Post.fromSnap(snap),
                                          uid: widget.uid)));
                                },
                                child: Image(
                                  image: NetworkImage(
                                      (snap.data()! as dynamic)['photoUrl']),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  );
                }),
            floatingActionButton: const AddPostButton(),
          );
  }
}
