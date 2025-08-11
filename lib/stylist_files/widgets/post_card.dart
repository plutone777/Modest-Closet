// lib/features/stylist/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mae_assignment/stylist_files/models/stylist_models.dart';
import 'package:mae_assignment/stylist_files/screens/user_profile_screen.dart';
import 'package:mae_assignment/stylist_files/screens/comment_screen.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({required this.post, Key? key}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late bool _isLiked;
  late bool _isSaved;
  late int _likeCount;
  late int _saveCount;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _isLiked =
        _currentUserId != null && widget.post.likedBy.contains(_currentUserId);
    _isSaved =
        _currentUserId != null && widget.post.savedBy.contains(_currentUserId);
    _likeCount = widget.post.likeCount;
    _saveCount = widget.post.saveCount;
    _commentCount = widget.post.commentCount;
  }

  void _toggleLike() async {
    if (_currentUserId == null) return;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);
    if (_isLiked) {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([_currentUserId]),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([_currentUserId]),
      });
    }
  }

  void _toggleSave() async {
    if (_currentUserId == null) return;
    setState(() {
      _isSaved = !_isSaved;
      _saveCount += _isSaved ? 1 : -1;
    });
    final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id);
    if (_isSaved) {
      await postRef.update({
        'savedBy': FieldValue.arrayUnion([_currentUserId]),
      });
    } else {
      await postRef.update({
        'savedBy': FieldValue.arrayRemove([_currentUserId]),
      });
    }
  }

  void _onCommentTapped() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommentsScreen(postId: widget.post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAuthorImage = widget.post.authorImageUrl.isNotEmpty;
    final bool hasPostImage = widget.post.postImageUrl.isNotEmpty;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.post.authorId.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            UserProfileScreen(userId: widget.post.authorId),
                  ),
                );
              }
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        hasAuthorImage
                            ? NetworkImage(widget.post.authorImageUrl)
                            : null,
                    child:
                        !hasAuthorImage
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.post.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          if (hasPostImage)
            Image.network(
              widget.post.postImageUrl,
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder:
                  (context, child, loadingProgress) =>
                      (loadingProgress == null)
                          ? child
                          : Container(
                            height: 400,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 400,
                    alignment: Alignment.center,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
            )
          else
            Container(
              height: 400,
              alignment: Alignment.center,
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 48,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionIcon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      _likeCount.toString(),
                      _toggleLike,
                      color: _isLiked ? Colors.red : Colors.black87,
                    ),
                    _buildActionIcon(
                      Icons.chat_bubble_outline,
                      _commentCount.toString(),
                      _onCommentTapped,
                    ),
                  ],
                ),
                _buildActionIcon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  _saveCount.toString(),
                  _toggleSave,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.post.description,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(
    IconData icon,
    String count,
    VoidCallback onTapAction, {
    Color color = Colors.black87,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapAction,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 6),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
