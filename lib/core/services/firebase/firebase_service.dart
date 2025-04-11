import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for handling Firestore and Firebase Storage operations
class FirebaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Get a reference to a Firestore collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a reference to a Firestore document
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  /// Get a document by its ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String documentId,
  ) async {
    debugPrint('Fetching document: $collection/$documentId');
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      debugPrint('Document exists: ${doc.exists}');
      return doc;
    } catch (e) {
      debugPrint('Error fetching document: $e');
      rethrow;
    }
  }

  /// Get all documents in a collection
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String collection,
  ) async {
    return await _firestore.collection(collection).get();
  }

  /// Get documents based on query conditions
  Future<QuerySnapshot<Map<String, dynamic>>> getDocumentsWithQuery(
    String collection, {
    String? field,
    dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (field != null && value != null) {
      query = query.where(field, isEqualTo: value);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  /// Add a new document to a collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.collection(collection).add(data);
  }

  /// Set a document with a specific ID
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await _firestore.collection(collection).doc(documentId).set(
          data,
          SetOptions(merge: merge),
        );
  }

  /// Update an existing document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  /// Delete a document
  Future<void> deleteDocument(
    String collection,
    String documentId,
  ) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  /// Upload a file to Firebase Storage
  Future<String> uploadFile(
    String path,
    File file, {
    Map<String, String>? metadata,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(
        file, SettableMetadata(contentType: metadata?['contentType']));
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  /// Listen to changes in a document
  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  /// Listen to changes in a collection
  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String collection, {
    String? field,
    dynamic value,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    if (field != null && value != null) {
      query = query.where(field, isEqualTo: value);
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Run a Firestore transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transaction,
  ) async {
    return await _firestore.runTransaction(transaction);
  }

  /// Get a batch for performing multiple write operations
  WriteBatch batch() {
    return _firestore.batch();
  }
}
