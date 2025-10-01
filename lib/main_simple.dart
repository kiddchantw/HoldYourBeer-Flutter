import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: SimpleTestApp(),
    ),
  );
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'HoldYourBeer Test',
          debugShowCheckedModeBanner: false,
          home: const TestHomeScreen(),
        );
      },
    );
  }
}

class TestHomeScreen extends StatefulWidget {
  const TestHomeScreen({super.key});

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  int _currentIndex = 1; // 預設在中間頁面

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('底部導航測試'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 圖表頁面
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 64),
                SizedBox(height: 16),
                Text('圖表統計頁面', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          // 啤酒列表頁面
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_bar, size: 64),
                SizedBox(height: 16),
                Text('啤酒列表頁面', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          // 會員頁面
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 64),
                SizedBox(height: 16),
                Text('會員資料頁面', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左側按鈕
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: Icon(
                  Icons.home,
                  size: 24,
                  color: _currentIndex == 0 ? Colors.orange : Colors.grey,
                ),
              ),
            ),
            // 中間按鈕
            SizedBox(
              width: 80,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _currentIndex = 1);
                    _showAddBeerDialog();
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            // 右側按鈕
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: _currentIndex == 2 ? Colors.orange : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBeerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 300,
        child: Column(
          children: [
            const Text(
              '新增啤酒',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text('新增啤酒功能測試'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ],
        ),
      ),
    );
  }
}