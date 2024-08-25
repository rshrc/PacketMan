// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';

class CreateCollectionDialog extends StatefulWidget {
  final int projectID;
  const CreateCollectionDialog({super.key, required this.projectID});

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Collection"),
      content: SizedBox(
        height: 400,
        width: 500,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final collectionId =
                await context.read<AppProvider>().createCollection(
                      widget.projectID,
                      nameController.text,
                      descriptionController.text,
                    );

            final collections = await context
                .read<AppProvider>()
                .loadCollections(widget.projectID);

            Navigator.pop(context);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
