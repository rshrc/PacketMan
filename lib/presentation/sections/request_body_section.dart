// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:drift/drift.dart' hide Column;
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';

class RequestBodySection extends StatelessWidget {
  const RequestBodySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(5),
        ),
        constraints: const BoxConstraints(minWidth: 400, minHeight: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Body:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Consumer<AppProvider>(builder: (context, appState, _) {
              return TextField(
                  controller: appState.bodyController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: '{ \n  "key": "value"\n}',
                    border: OutlineInputBorder(),
                  ),
                  onTapOutside: (_) {
                    appState.updateRequest(
                      request: appState.selectedRequest!.copyWith(
                        body: Value(appState.bodyController.text),
                      ),
                    );
                  },
                  onEditingComplete: () {
                    appState.updateRequest(
                      request: appState.selectedRequest!.copyWith(
                        body: Value(appState.bodyController.text),
                      ),
                    );
                  });
            })
          ],
        ),
      ),
    );
  }
}
