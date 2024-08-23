import 'package:flutter/material.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/presentation/forms/create_requests.dart';
import 'package:packet_man/presentation/request_list.dart';
import 'package:provider/provider.dart';

class CollectionList extends StatelessWidget {
  final int projectID;
  const CollectionList({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appState, _) {
      final collections = appState.collections[projectID] ?? [];
      return ListView.builder(
        shrinkWrap: true,
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(collection.name ?? "--",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      )),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // show dialog to create collection
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CreateRequestDialog(
                              collectionID: collection.id,
                            );
                          });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: RequestsList(collectionId: collection.id),
              ),
            ],
          );
        },
      );
    });
  }
}
