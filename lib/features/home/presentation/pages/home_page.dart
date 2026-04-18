import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/home_empty_view.dart';
import '../widgets/home_populated_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Toggle for demonstrating both states during development
  bool _isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        actions: [
          IconButton(
            icon: Icon(_isEmpty ? LucideIcons.listPlus : LucideIcons.trash2),
            tooltip: 'Toggle Empty State',
            onPressed: () {
              setState(() {
                _isEmpty = !_isEmpty;
              });
            },
          ),
        ],
      ),
      body: _isEmpty ? const HomeEmptyView() : const HomePopulatedView(),
    );
  }
}

