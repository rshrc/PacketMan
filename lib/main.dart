import 'package:flutter/material.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/application/providers.dart';
import 'package:packet_man/di/injection.dart';

import 'package:packet_man/presentation/forms/create_projects.dart';
import 'package:packet_man/presentation/project_list.dart';
import 'package:packet_man/presentation/request_test_body.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  runApp(const PacketMan());
}

class PacketMan extends StatelessWidget {
  const PacketMan({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'PacketMan',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
              disabledForegroundColor: Colors.grey.withOpacity(0.38),
              disabledBackgroundColor: Colors.grey.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.initApp();
  }

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PacketMan',
          style: TextStyle(
            color: Colors.orange,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Purge All Data"),
                      content: const Text(
                          "Are you sure you want to delete all data? This action cannot be undone."),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            // final database = AppDatabase();
                            await context.read<AppProvider>().purgeAllData();
                            Navigator.pop(context);
                          },
                          child: const Text("Purge"),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Purge"),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          // create project, but first open dialog box
                          showDialog(
                              context: context,
                              builder: (context) {
                                return const CreateProjectDialog();
                              });
                        },
                        child: const Text("Create Project")),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: ProjectsList(),
                    )
                  ],
                ),
              ),
            ),
          ),
          const Expanded(flex: 5, child: RequestTestBody()),
          const Expanded(
              flex: 2,
              child: SizedBox(
                width: 300,
              ))
        ],
      ),
    );
  }
}
