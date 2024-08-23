import 'package:flutter/material.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/presentation/forms/create_requests.dart';
import 'package:packet_man/utils/colors.dart';
import 'package:provider/provider.dart';

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(request.requestType ?? "--",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color:
                          getColorForRequestType(request.requestType ?? "--"),
                    )),
                const SizedBox(width: 10),
                Text(request.name ?? "--",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    )),
              ],
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
