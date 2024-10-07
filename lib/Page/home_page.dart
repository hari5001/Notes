import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/service/firestore.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firestoreService.addNote(textController.text);
              } else {
                firestoreService.updateNotes(docID, textController.text);
              }
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
          stream: firestoreService.getNoteStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List noteList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = noteList[index];

                  String docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String noteText = data['note'];
                  return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () => openNoteBox(docID: docID),
                              icon: const Icon(Icons.settings)),
                          IconButton(
                              onPressed: () =>
                                  firestoreService.deleteNotes(docID),
                              icon: const Icon(Icons.delete)),
                        ],
                      ));
                },
              );
            } else {
              return const Text("No Notes...,");
            }
          }),
    );
  }
}
