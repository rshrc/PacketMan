// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/utils/colors.dart';

class RequestsList extends StatelessWidget {
  final int collectionId;
  const RequestsList({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appState, _) {
      final requests = appState.requests[collectionId] ?? [];
      return ListView.separated(
        shrinkWrap: true,
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return InkWell(
            onTap: () {
              context.read<AppProvider>().selectRequest(request);
            },
            child: Container(
              decoration: BoxDecoration(
                color: appState.selectedRequest?.id != request.id
                    ? null
                    : Colors.orangeAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(request.requestType ?? "--",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getColorForRequestType(
                              request.requestType ?? "--"),
                        )),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(request.name ?? "--",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 4);
        },
      );
    });
  }
}
