import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:back4app_posts_app/screens/MyPosts.dart';
import 'package:back4app_posts_app/screens/create_post.dart';

import 'profile_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  var totallikes;
  ParseUser? currentUser;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    final user = await ParseUser.currentUser();
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Post Feed"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getPostsAndUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error ${snapshot.error}"),
                    );
                  } else {
                    List<Map<String, dynamic>> data =
                        snapshot.data as List<Map<String, dynamic>>;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final post = data[index]['post'] as ParseObject;
                        final user = post.get<ParseUser>('userid');
                        final fetchedUserImage =
                            data[index]['userImage'] as ParseFile?;
                        final fetchedPostImages =
                            data[index]['postImageUrls'] as List<String>;

                        print('Post $index images: $fetchedPostImages');

                        totallikes = post['likes'].toString();
                        return FutureBuilder(
                          future: getUserData(user),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox.shrink();
                            } else if (userSnapshot.hasError) {
                              return const Text("Error fetching user");
                            } else {
                              final userData =
                                  userSnapshot.data as Map<String, dynamic>;
                              final fetchedUser =
                                  userData['user'] as ParseUser?;
                              final fetchedUsername =
                                  fetchedUser?.get<String>('username') ??
                                      'Unknown User';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      fetchedUserImage != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: SizedBox(
                                                height: 60,
                                                width: 60,
                                                child: Image.network(
                                                  fetchedUserImage.url!,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            )
                                          : const Icon(Icons.person,
                                              size: 30, color: Colors.black),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fetchedUsername,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.75,
                                            child: Text(
                                              post['description'],
                                              style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 4,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: double.maxFinite,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: fetchedPostImages.isNotEmpty
                                          ? CarouselSlider.builder(
                                              itemCount:
                                                  fetchedPostImages.length,
                                              itemBuilder: (context, imageIndex,
                                                  realIndex) {
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Image.network(
                                                        fetchedPostImages[
                                                            imageIndex],
                                                        fit: BoxFit.cover,
                                                        width: double
                                                            .infinity, // Ensure image takes full width
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: fetchedPostImages
                                                                      .length >
                                                                  1
                                                              ? Container(
                                                                  width: 40,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      color: Colors
                                                                          .black),
                                                                  child: Text(
                                                                    '${imageIndex + 1}/${fetchedPostImages.length}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                )
                                                              : null),
                                                    ),
                                                  ],
                                                );
                                              },
                                              options: CarouselOptions(
                                                height: 250,
                                                enlargeCenterPage: false,
                                                autoPlay: false,
                                                autoPlayCurve:
                                                    Curves.fastOutSlowIn,
                                                enableInfiniteScroll: false,
                                                autoPlayAnimationDuration:
                                                    Duration(milliseconds: 800),
                                                viewportFraction: 1.0,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_not_supported,
                                              size: 25,
                                              color: Colors.black,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          FutureBuilder(
                                              future: isPostLiked(
                                                  post.objectId!,
                                                  currentUser!.objectId!),
                                              builder: ((context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Icon(
                                                    CupertinoIcons.heart,
                                                    color: Colors.black,
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return const Icon(
                                                    CupertinoIcons.heart,
                                                    color: Colors.black,
                                                  );
                                                } else {
                                                  bool isLiked =
                                                      snapshot.data as bool;
                                                  return IconButton(
                                                    onPressed: () async {
                                                      bool isLiked =
                                                          await isPostLiked(
                                                              post.objectId!,
                                                              currentUser!
                                                                  .objectId!);
                                                      if (isLiked) {
                                                        await handleUnlikePost(
                                                            post);
                                                      } else {
                                                        await handleLikePost(
                                                            post);
                                                      }
                                                      setState(() {});
                                                    },
                                                    icon: FutureBuilder(
                                                      future: isPostLiked(
                                                          post.objectId!,
                                                          currentUser!
                                                              .objectId!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Icon(
                                                            CupertinoIcons
                                                                .heart,
                                                            color: Colors.black,
                                                          );
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return const Icon(
                                                            CupertinoIcons
                                                                .heart,
                                                            color: Colors.black,
                                                          );
                                                        } else {
                                                          bool isLiked =
                                                              snapshot.data
                                                                  as bool;
                                                          return Icon(
                                                            CupertinoIcons
                                                                .heart,
                                                            color: isLiked
                                                                ? Colors.red
                                                                : Colors.black,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  );
                                                }
                                              })),
                                          Text("${post['likes']} likes"
                                              .toString()),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                showCommentsBottomSheet(
                                                    context, post.objectId!);
                                              },
                                              icon: const Icon(Icons.comment))
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showCommentsBottomSheet(BuildContext context, String postId) async {
    TextEditingController commentsController = TextEditingController();
    List<Map<String, dynamic>> comments = await fetchComments(postId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: comments.isNotEmpty
                          ? ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                return FutureBuilder<ParseFile?>(
                                    future: getUserProfileImage(
                                        comments[index]['author']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: SizedBox.shrink());
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundImage:
                                                snapshot.data != null
                                                    ? NetworkImage(
                                                        snapshot.data!.url!)
                                                    : null,
                                          ),
                                          title: Text(
                                            '${comments[index]['author'] ?? 'Unknown'}',
                                          ),
                                          subtitle:
                                              Text(comments[index]['text']),
                                        );
                                      }
                                    });
                              },
                            )
                          : const Center(child: Text('No comments yet.')),
                    ),
                    TextField(
                      controller: commentsController,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            String comment = commentsController.text;
                            if (comment.isNotEmpty) {
                              await addComment(postId, comment);
                              commentsController.clear();
                              setState(() {
                                comments.add({
                                  'author': currentUser?.username ?? 'Unknown',
                                  'text': comment,
                                });
                              });
                            }
                          },
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Posts'))
          ..whereEqualTo('objectId', postId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final ParseObject post = response.results!.first;
      dynamic commentsField = post.get('comments');

      if (commentsField is List) {
        List<Map<String, dynamic>> comments = [];
        for (var comment in commentsField) {
          if (comment is Map<String, dynamic>) {
            comments.add(comment);
          }
        }
        return comments;
      } else {
        // Handle case where comments field is not a list
        print(
            'Unexpected data type for comments field: ${commentsField.runtimeType}');
        return [];
      }
    } else {
      print('Failed to find post with ID: $postId');
      return [];
    }
  }

  Future<void> addComment(String postId, String comment) async {
    // Retrieve the current user
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Posts'))
          ..whereEqualTo('objectId', postId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final ParseObject post = response.results!.first;
      dynamic commentsField = post.get('comments');

      List<dynamic> comments;
      if (commentsField is List) {
        comments = commentsField;
      } else {
        comments = [];
      }

      comments.add({
        'author': currentUser?.username ?? 'Unknown',
        'text': comment,
      });
      post.set<List<dynamic>>('comments', comments);

      final saveResponse = await post.save();

      if (!saveResponse.success) {
        print('Failed to add comment: ${saveResponse.error!.message}');
      }
    } else {
      print('No post found with this ID: $postId');
    }
  }

  Future<ParseFile?> getUserProfileImage(String username) async {
    final QueryBuilder<ParseUser> queryBuilder =
        QueryBuilder<ParseUser>(ParseUser.forQuery())
          ..whereEqualTo('username', username)
          ..setLimit(1);

    final ParseResponse response = await queryBuilder.query();

    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final ParseUser user = response.results!.first;
      return user.get<ParseFile>('profile');
    } else {
      return null;
    }
  }

  Future<void> handleLikePost(ParseObject post) async {
    await likePost(post.objectId!, currentUser!.objectId!);
    await incrementLikes(post.objectId!);
  }

  Future<void> handleUnlikePost(ParseObject post) async {
    await unlikePost(post.objectId!, currentUser!.objectId!);
    await decrementLikes(post.objectId!);
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('PostLike'))
          ..whereEqualTo('post_id', postId)
          ..whereEqualTo('user_id', userId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final List<ParseObject> likedPosts =
          response.results as List<ParseObject>;
      return likedPosts.isNotEmpty;
    } else {
      return false;
    }
  }

  Future<void> likePost(String postId, String userId) async {
    final ParseObject postLike = ParseObject('PostLike')
      ..set<String>('post_id', postId)
      ..set<String>('user_id', userId)
      ..set<bool>('liked', true);

    await postLike.save();
  }

  Future<void> unlikePost(String postId, String userId) async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('PostLike'))
          ..whereEqualTo('post_id', postId)
          ..whereEqualTo('user_id', userId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final ParseObject postLike = response.results!.first;
      await postLike.delete();
    }
  }

  Future<void> incrementLikes(String postId) async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Posts'))
          ..whereEqualTo('objectId', postId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final ParseObject post = response.results!.first;

      int likes = post.get<int>('likes') ?? 0;
      likes++;
      post.set<int>('likes', likes);
      await post.save();
    }
  }

  Future<void> decrementLikes(String postId) async {
    final QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Posts'))
          ..whereEqualTo('objectId', postId);

    final ParseResponse response = await queryBuilder.query();

    if (response.success && response.results != null) {
      final ParseObject post = response.results!.first;

      int likes = post.get<int>('likes') ?? 0;
      likes--;
      post.set<int>('likes', likes);
      await post.save();
    }
  }

  Future<List<Map<String, dynamic>>> getPostsAndUserData() async {
    QueryBuilder<ParseObject> queryPosts =
        QueryBuilder<ParseObject>(ParseObject('Posts'));

    final ParseResponse apiResponse = await queryPosts.query();

    if (apiResponse.success && apiResponse.results != null) {
      List<ParseObject> posts = apiResponse.results as List<ParseObject>;
      List<Future<ParseFile?>> userImageFutures = [];
      List<Future<List<String>>> postImageUrlsFutures = [];

      for (var post in posts) {
        ParseUser? user = post.get<ParseUser>('userid');
        userImageFutures.add(getUserImage(user));
        postImageUrlsFutures.add(getPostImageUrls(post));
      }

      List<ParseFile?> userImages = await Future.wait(userImageFutures);
      List<List<String>> postImageUrlsList =
          await Future.wait(postImageUrlsFutures);

      List<Map<String, dynamic>> result = [];
      for (int i = 0; i < posts.length; i++) {
        result.add({
          'post': posts[i],
          'userImage': userImages[i],
          'postImageUrls': postImageUrlsList[i],
        });
      }

      return result;
    } else {
      return [];
    }
  }

  Future<ParseFile?> getUserImage(ParseUser? user) async {
    if (user != null) {
      ParseObject fetchedUser = await user.fetch();
      return fetchedUser.get<ParseFile>('profile');
    }
    return null;
  }

  Future<List<String>> getPostImageUrls(ParseObject post) async {
    // Get the array of files
    final files = post.get<List<dynamic>>('files');

    // Debug print to check the files data
    print('Files data: $files');

    // Check if files are not null and is a List of dynamic
    if (files == null || files.isEmpty) {
      return [];
    }

    // Extract URLs from the files
    List<String> urls = [];
    for (var file in files) {
      if (file is ParseFile) {
        urls.add(file.url!);
      } else if (file is Map<String, dynamic> && file['url'] != null) {
        urls.add(file['url']);
      }
    }

    // Return the list of URLs
    return urls;
  }

  Future<Map<String, dynamic>> getUserData(ParseUser? user) async {
    if (user != null) {
      ParseObject fetchedUser = await user.fetch();
      ParseFile? userImage = fetchedUser.get<ParseFile>('profile');

      return {
        'user': fetchedUser,
        'userImage': userImage,
      };
    }
    return {
      'user': null,
      'userImage': null,
    };
  }
}
