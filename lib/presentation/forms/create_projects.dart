// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Project"),
      content: SizedBox(
        height: 200,
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
            // create project
            // final database = AppDatabase();
            final projectId = await context.read<AppProvider>().createProject(
                  nameController.text,
                  descriptionController.text,
                );

            // load projects
            final projects = await context.read<AppProvider>().loadProjects();
            Navigator.pop(context);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
