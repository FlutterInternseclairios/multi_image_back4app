import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:back4app_posts_app/screens/bottom_bar.dart';
import 'package:back4app_posts_app/screens/posts_screen.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController descriptionController = TextEditingController();
  ParseUser? currentUser;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> getUser() async {
    final user = await ParseUser.currentUser();
    setState(() {
      currentUser = user;
    });
  }

  List<XFile>? pickedFiles;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Create Post'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Container(
                width: double.maxFinite,
                height: 250,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blue)),
                child: pickedFiles != null && pickedFiles!.isNotEmpty
                    ? Row(
                        children: List.generate(
                          pickedFiles!.length,
                          (index) => Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: kIsWeb
                                      ? NetworkImage(pickedFiles![index].path)
                                      : FileImage(
                                              File(pickedFiles![index].path))
                                          as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text('Click here to pick images from Gallery'),
                      ),
              ),
              onTap: () async {
                final List<XFile>? images = await ImagePicker().pickMultiImage(
                  imageQuality: 50,
                  maxWidth: 800,
                  maxHeight: 600,
                );

                if (images != null && images.length <= 5) {
                  setState(() {
                    pickedFiles = images;
                  });
                } else if (images != null && images.length > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'You can only select up to 5 images',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: "Your Thoughts",
                prefixIcon: Icon(Icons.description_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              maxLength: 200,
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              child: ElevatedButton(
                child: Text(
                  'Upload files',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed:
                    isLoading || pickedFiles == null || pickedFiles!.isEmpty
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });

                            List<ParseFileBase> parseFiles = [];

                            for (var file in pickedFiles!) {
                              ParseFileBase parseFile;

                              if (kIsWeb) {
                                parseFile = ParseWebFile(
                                  await file.readAsBytes(),
                                  name: file.name,
                                );
                              } else {
                                parseFile = ParseFile(File(file.path));
                              }

                              await parseFile.save();
                              parseFiles.add(parseFile);
                            }

                            final post = ParseObject('Posts')
                              ..set('files', parseFiles)
                              ..set('description', descriptionController.text)
                              ..set('likes', 0)
                              ..set('comments', [])
                              ..set(
                                  'userid',
                                  (ParseObject('_User')
                                    ..objectId = currentUser!.objectId));

                            await post.save();

                            setState(() {
                              isLoading = false;
                            });

                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text(
                                  'Post Added Successfully',
                                  style: TextStyle(color: Colors.white),
                                ),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.blue,
                              ));

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NavigationMenu()),
                            );
                          },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
