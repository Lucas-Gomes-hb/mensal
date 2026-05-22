import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/month_card.dart';
import 'month_calculations_screen.dart';
import 'copy_calculation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final int _year = DateTime.now().year;
  final int _currentMonth = DateTime.now().month;
  final Map<int, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummaries();
  }

  Future<void> _loadSummaries() async {
    setState(() => _loading = true);
    final results = await Future.wait(
      List.generate(
          12, (i) => _storage.loadMonthCalculations(_year, i + 1)),
    );
    final map = <int, int>{};
    for (var i = 0; i < 12; i++) {
      map[i + 1] = results[i].length;
    }
    if (mounted) {
      setState(() {
        _counts.addAll(map);
        _loading = false;
      });
    }
  }

  Future<void> _openMonth(int month) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MonthCalculationsScreen(year: _year, month: month),
      ),
    );
    _loadSummaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.file_copy_outlined),
                tooltip: 'Copiar cálculo',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CopyCalculationScreen(year: _year),
                    ),
                  );
                  _loadSummaries();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mensal  $_year',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final month = index + 1;
                    final count = _counts[month] ?? 0;
                    final isPast = month < _currentMonth;
                    final isCurrent = month == _currentMonth;
                    return MonthCard(
                      month: month,
                      isCurrent: isCurrent,
                      isPast: isPast,
                      count: count > 0 ? count : null,
                      onTap: () => _openMonth(month),
                    );
                  },
                  childCount: 12,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
