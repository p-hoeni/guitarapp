import 'package:flutter/material.dart';
import 'package:guitar_app/song/song_model/song_model.dart';
import 'package:guitar_app/song/song_service/songs_provider.dart';
import 'package:guitar_app/song/song_list/songs.dart';
import 'package:guitar_app/shared/utils.dart';
import 'package:guitar_app/song/song_edit/song_form_widget.dart';
import 'package:provider/provider.dart';

class EditSong extends StatefulWidget {
  final Song song;

  const EditSong({Key? key, required this.song}) : super(key: key);

  @override
  _EditSongState createState() => _EditSongState();
}

class _EditSongState extends State<EditSong> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String description;
  late List<String> performances;

  @override
  void initState() {
    super.initState();

    title = widget.song.title;
    description = widget.song.description;
    performances = widget.song.performances;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Song bearbeiten'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                final provider =
                    Provider.of<SongsProvider>(context, listen: false);
                provider.removeSong(widget.song);
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Songs()));
                Utils.showSnackBar(context, 'Song gelöscht');
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SongFormWidget(
            title: title,
            description: description,
            performances: performances,
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
            onChangedPerformances: (performances) => setState(() => this.performances = performances),
            onSavedSong: saveSong,
          ),
        ),
      ),
    );
  }

  Future<void> saveSong() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    } else {
      final provider = Provider.of<SongsProvider>(context, listen: false);

      await provider.updateSong(widget.song, title, description, performances);
      Utils.showSnackBar(context, 'Song bearbeitet');
      Navigator.of(context).pop();
    }
  }
}
