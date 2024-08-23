import 'package:flutter/material.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/presentation/collection_list.dart';
import 'package:packet_man/presentation/forms/create_collection.dart';
import 'package:provider/provider.dart';

class ProjectsList extends StatelessWidget {
  const ProjectsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appState, _) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: appState.projects.length ?? 0,
        itemBuilder: (context, index) {
          final project = appState.projects.values.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // show dialog to create collection
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CreateCollectionDialog(projectID: project.id);
                        },
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CollectionList(projectID: project.id),
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 16);
        },
      );
    });
  }
}
