import 'package:flutter/widgets.dart';

class Mutation extends StatefulWidget {
  @override
  _MutationState createState() => _MutationState();
}

class _MutationState extends State<Mutation> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(),
      ),
    );
  }
}