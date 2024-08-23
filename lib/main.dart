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
        ),
        home: const MyHomePage(),
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
        title: const Text('PacketMan',
            style: TextStyle(
              color: Colors.orange,
            )),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
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
          const Expanded(flex: 5, child: RequestTestBody()),
        ],
      ),
    );
  }
}
