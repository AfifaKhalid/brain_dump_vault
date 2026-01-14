import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../widgets/category_card.dart';
import 'add_thought_screen.dart';
import 'category_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryCounts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategoryCounts();
  }

  void _loadCategoryCounts() {
    setState(() {
      _categoryCounts = HiveService.getCategoryCounts();
    });
  }

  void _navigateToCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryDetailScreen(category: category),
      ),
    ).then((_) => _loadCategoryCounts());
  }

  void _navigateToAddThought() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddThoughtScreen()),
    );
    _loadCategoryCounts();
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = HiveService.defaultCategories;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Brain Dump Vault',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: _navigateToSearch,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // 👈 important
            children: [
              Text(
                'Got something on your mind?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF3c2f2f).withAlpha(180),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              /// IDEAS
              CategoryCard(
                category: categories[0],
                thoughtCount: _categoryCounts[categories[0]] ?? 0,
                onTap: () => _navigateToCategory(categories[0]),
                index: 0,
              ),
              const SizedBox(height: 14),

              /// WORRIES
              CategoryCard(
                category: categories[1],
                thoughtCount: _categoryCounts[categories[1]] ?? 0,
                onTap: () => _navigateToCategory(categories[1]),
                index: 1,
              ),
              const SizedBox(height: 14),

              /// TASKS
              CategoryCard(
                category: categories[2],
                thoughtCount: _categoryCounts[categories[2]] ?? 0,
                onTap: () => _navigateToCategory(categories[2]),
                index: 2,
              ),
              const SizedBox(height: 14),

              /// RANDOM
              CategoryCard(
                category: categories[3],
                thoughtCount: _categoryCounts[categories[3]] ?? 0,
                onTap: () => _navigateToCategory(categories[3]),
                index: 3,
              ),

              SizedBox(height: bottomInset + 96),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddThought,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Thought',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
