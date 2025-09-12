import 'package:flutter/material.dart';

class FutureEg extends StatefulWidget {
  const FutureEg({super.key});

  @override
  State<FutureEg> createState() => _FutureEgState();
}

class _FutureEgState extends State<FutureEg> {
  Future<String> fetchData() async {
    await Future.delayed(const Duration(seconds: 5));
    return 'Data is loaded';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Eg'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return Text(snapshot.requireData);
          },
        ),
      ),
    );
  }
}