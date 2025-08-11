// lib/features/stylist/models/stylist_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Your other models (StylistProfile, Post, etc.) are fine and do not need changes.
// ... (keep your other model classes as they are) ...
class StylistProfile {
  final String uid;
  final String username;
  final String email;
  final String role;
  final String profileImageUrl;
  final String profession;
  final int followersCount;
  final int followingCount;

  StylistProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.role,
    required this.profileImageUrl,
    required this.profession,
    required this.followersCount,
    required this.followingCount,
  });

  factory StylistProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StylistProfile(
      uid: doc.id,
      username: data['username'] ?? 'Stylist Name',
      email: data['email'] ?? '',
      role: data['role'] ?? 'stylist',
      profileImageUrl: data['profileImageUrl'] ?? '',
      profession: data['profession'] ?? 'Fashion Stylist',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }
}

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final String postImageUrl;
  final String description;
  final Timestamp timestamp;
  final List<String> likedBy;
  final List<String> savedBy;
  final int commentCount;

  int get likeCount => likedBy.length;
  int get saveCount => savedBy.length;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.postImageUrl,
    required this.description,
    required this.timestamp,
    required this.likedBy,
    required this.savedBy,
    required this.commentCount,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown Author',
      authorImageUrl: data['authorImageUrl'] ?? '',
      postImageUrl: data['postImageUrl'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
      commentCount: data['commentCount'] ?? 0,
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final Timestamp timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return NotificationItem(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      body: data['body'] ?? 'No content.',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}

class Comment {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String authorImageUrl;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.authorImageUrl,
    required this.timestamp,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      text: data['text'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorImageUrl: data['authorImageUrl'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}


// ======== MODEL FOR THE DASHBOARD STATISTICS (FINAL CORRECTED VERSION) ========
class StylistPerformanceStats {
  final int profileViews;
  final int newFollowers;
  final int postEngagement;

  StylistPerformanceStats({
    required this.profileViews,
    required this.newFollowers,
    required this.postEngagement,
  });

  // This factory now correctly reads the fields from your 'stylist_stats' collection document
  factory StylistPerformanceStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {}; // Safely handle null data

    return StylistPerformanceStats(
      // The field names here now match your screenshot of the 'stylist_stats' collection
      profileViews: data['profileViews'] ?? 0,
      newFollowers: data['newFollowers'] ?? 0,
      postEngagement: data['postEngagement'] ?? 0,
    );
  }
}

// ... (keep your other model classes like ClientRequest and ChatMessage as they are) ...
class ClientRequest {
  final String id;
  final String name;
  final int age;
  final String profession;
  final String imageUrl;

  ClientRequest({
    required this.id,
    required this.name,
    required this.age,
    required this.profession,
    required this.imageUrl,
  });

  factory ClientRequest.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ClientRequest(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      age: data['age'] ?? 0,
      profession: data['profession'] ?? 'No Profession',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
class ChatMessage {
  final String id;
  final String senderName;
  final String senderImageUrl;
  final String lastMessage;
  final String timestamp;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderImageUrl,
    required this.lastMessage,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderName: data['senderName'] ?? 'Unknown Sender',
      senderImageUrl: data['senderImageUrl'] ?? '',
      lastMessage: data['lastMessage'] ?? '...',
      timestamp: data['timestamp'] ?? '',
    );
  }
}
