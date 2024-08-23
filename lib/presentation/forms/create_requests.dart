import 'package:flutter/material.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:provider/provider.dart';

class CreateRequestDialog extends StatefulWidget {
  final int collectionID;

  const CreateRequestDialog({super.key, required this.collectionID});

  @override
  State<CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<CreateRequestDialog> {
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        )),
        title: const Text("Create Request"),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
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
              // create request
              // final database = AppDatabase();
              await context.read<AppProvider>().createRequest(
                    widget.collectionID,
                    nameController.text,
                  );

              final requests = await context
                  .read<AppProvider>()
                  .loadRequests(widget.collectionID);

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}
