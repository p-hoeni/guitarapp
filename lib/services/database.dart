import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guitar_app/models/performance.dart';
import 'package:guitar_app/models/song.dart';
import 'package:guitar_app/utils.dart';

class DatabaseService {
  // Performance CRUD methods

  static Future<String> createPerformance(Performance performance) async {
    final docPerformance =
        FirebaseFirestore.instance.collection('performances').doc();
    performance.id = docPerformance.id;
    await docPerformance.set(performance.toJson());

    return docPerformance.id;
  }

  static Stream<List<Performance>> readPerformances() {
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('performances')
        .orderBy(PerformanceField.createdTime, descending: true)
        .snapshots();

    return stream.map((event) => event.docs
        .map((doc) => Performance(
              id: doc['id'],
              title: doc['title'],
              createdTime: Utils.toDateTime(doc['createdTime']),
              description: doc['description'],
            ))
        .toList());
  }

  static Future<String> deletePerformance(Performance performance) async {
    // delete performanceID from songs that include it in performances array
    var batch = FirebaseFirestore.instance.batch();

    var songsSnapshot = await FirebaseFirestore.instance
        .collection('songs')
        .where('performances', arrayContains: performance.id)
        .get();

    for (var songDoc in songsSnapshot.docs) {
      Song song = Song.fromJson(songDoc.data());
      bool success = song.performances.remove(performance.id);
      if (success) {
        if (song.performances.isEmpty) {
          await addUnsortedPerformance(song);
        }

        batch.update(
            FirebaseFirestore.instance.collection('songs').doc(songDoc.id),
            {'performances': song.performances});
      }
    }

    await batch.commit();

    // delete performance
    final docPerformance = FirebaseFirestore.instance
        .collection('performances')
        .doc(performance.id);
    await docPerformance.delete();

    return docPerformance.id;
  }

  static Future<String> updatePerformance(Performance performance) async {
    final docPerformance = FirebaseFirestore.instance
        .collection('performances')
        .doc(performance.id);
    await docPerformance.update(performance.toJson());
    return docPerformance.id;
  }

  // Song CRUD methods

  static Future<Song> addUnsortedPerformance(Song song) async {
    // get "Unsortiert" performance & add it to Song
    var unsortedPerformanceSnapshot = await FirebaseFirestore.instance
        .collection('performances')
        .limit(1)
        .where('title', isEqualTo: 'Unsortiert')
        .get();
    var unsortedPerformance =
        Performance.fromJson(unsortedPerformanceSnapshot.docs.first.data());
    List<String> performances = [];
    performances.add(unsortedPerformance.id);

    song.performances = performances;
    return song;
  }

  static Future<String> createSong(Song song) async {
    await addUnsortedPerformance(song);

    // set Song ID and add Song to Firebase
    final docSong = FirebaseFirestore.instance.collection('songs').doc();
    song.id = docSong.id.trim();
    await docSong.set(song.toJson());

    return docSong.id;
  }

  static Stream<List<Song>> readSongs() {
    Stream<QuerySnapshot> stream = FirebaseFirestore.instance
        .collection('songs')
        .orderBy(SongField.createdTime, descending: true)
        .snapshots();

    return stream.map((event) => event.docs.map((doc) {
          List<String> performancesIDs = [];
          for (var per in doc['performances']) {
            performancesIDs.add(per.toString());
          }

          return Song(
            id: doc['id'],
            title: doc['title'],
            createdTime: Utils.toDateTime(doc['createdTime']),
            description: doc['description'],
            performances: performancesIDs,
          );
        }).toList());
  }

  static Future<String> updateSong(Song song) async {
    final docSong = FirebaseFirestore.instance.collection('songs').doc(song.id);
    await docSong.update(song.toJson());
    return docSong.id;
  }

  static Future<String> deleteSong(Song song) async {
    final docSong = FirebaseFirestore.instance.collection('songs').doc(song.id);
    await docSong.delete();
    return docSong.id;
  }
}
