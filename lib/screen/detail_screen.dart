import 'package:amigos_hackalearn/model/user.dart' as model;
import 'package:amigos_hackalearn/screen/post_screen.dart';
import 'package:amigos_hackalearn/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../model/post.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final String uid;
  const DetailScreen({Key? key, required this.post, required this.uid})
      : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final model.User user;
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
      print(user);
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
    DateTime createddate = widget.post.dateTime;
    String formatteddate = DateFormat('yyyy-MM-dd').format(createddate);
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final TextEditingController commentController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: whiteColor,
        title: Text(
          widget.post.postTitle,
          style: const TextStyle(color: primaryColor),
        ),
        actions: currentUid == widget.post.uid
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: primaryColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                    //수정상태와 최초 글쓰기 상태를 PostScreen에서 설정해줘야
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostScreen(uid: widget.post.uid),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: primaryColor,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('게시글 삭제'),
                        content: const Text('게시글을 삭제할까요?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                          ),
                          TextButton(
                            child: Text(
                              '확인',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop(true);
                              try {
                                Navigator.pop(context);
                                final FirebaseFirestore firestore =
                                    FirebaseFirestore.instance;
                                DateTime day = widget.post.dateTime;
                                String tmpDate = day.year.toString() +
                                    day.month.toString() +
                                    day.day.toString();

                                DocumentReference docUser = FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(widget.post.uid);

                                docUser.update({
                                  "saved": FieldValue.increment(
                                      widget.post.saved * (-1)),
                                  "implements":
                                      FieldValue.arrayRemove([tmpDate])
                                });
                                firestore
                                    .collection('posts')
                                    .doc(widget.post.id)
                                    .delete();
                              } catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "삭제하지 못했습니다.",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              color: whiteColor,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              margin: const EdgeInsets.all(30),
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    //프로필 사진 & author
                    ListTile(
                      leading: const CircleAvatar(),
                      title: Text(
                        widget.post.author,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    //게시물 사진
                    Center(child: Image.network(widget.post.photoUrl)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(25, 10, 0, 0),
                        child: Text(
                          widget.post.content,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    //발행 날짜
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(
                            flex: 20,
                          ),
                          Text(
                            formatteddate,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Spacer(
                            flex: 4,
                          ),
                          Text(
                            widget.post.saved.toString(),
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Spacer(),
                          const Text(
                            '원 절약',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.post.id)
                  .collection('comments')
                  .orderBy(
                    'datePublished',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) => CommentCard(
                    snap: (snapshot.data! as dynamic).docs[index].data(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: isLoading
            ? Container()
            : Container(
                height: kToolbarHeight,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                      radius: 18,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Comment as ${user.username}',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        try {
                          if (commentController.text.isNotEmpty) {
                            String commentId = const Uuid().v1();
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.post.id)
                                .collection('comments')
                                .doc(commentId)
                                .set({
                              'profileImage': user.photoUrl,
                              'name': user.username,
                              'text': commentController.text,
                              'commentId': commentId,
                              'datePublished': DateTime.now(),
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }

                        setState(() {
                          commentController.text = '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: const Text(
                          'Post',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CommentCard extends StatefulWidget {
  final snap;
  const CommentCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['profileImage']),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '  ${widget.snap['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
