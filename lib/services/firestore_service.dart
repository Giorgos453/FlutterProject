import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/leaderboard_entry.dart';
import '../models/user_model.dart';

/// Thin wrapper around Cloud Firestore — no Flutter imports, no UI logic.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Fetches the [SolUser] for [uid], or `null` if the document is missing.
  Future<SolUser?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return SolUser.fromMap(doc.data()!);
  }

  /// Persists the full [user] state under [uid] (merge to avoid clobbering
  /// fields written by other clients or Cloud Functions).
  Future<void> saveUser(String uid, SolUser user) =>
      _users.doc(uid).set(user.toMap(), SetOptions(merge: true));

  /// Creates a default user document if one does not already exist.
  Future<void> createUserIfMissing(String uid, {String displayName = ''}) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) return;
    final user = SolUser(displayName: displayName);
    await _users.doc(uid).set(user.toMap());
  }

  /// Returns up to [limit] users ordered by XP descending.
  Future<List<LeaderboardEntry>> fetchLeaderboard({int limit = 20}) async {
    final snapshot =
        await _users.orderBy('xp', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return LeaderboardEntry(
        uid: doc.id,
        displayName: data['displayName'] as String? ?? 'Anonymous',
        xp: data['xp'] as int? ?? 0,
      );
    }).toList();
  }
}
