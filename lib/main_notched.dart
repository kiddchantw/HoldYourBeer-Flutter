import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: NotchedTestApp(),
    ),
  );
}

class NotchedTestApp extends StatelessWidget {
  const NotchedTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'HoldYourBeer Notched',
          debugShowCheckedModeBanner: false,
          home: const NotchedHomeScreen(),
        );
      },
    );
  }
}

class NotchedHomeScreen extends StatefulWidget {
  const NotchedHomeScreen({super.key});

  @override
  State<NotchedHomeScreen> createState() => _NotchedHomeScreenState();
}

class _NotchedHomeScreenState extends State<NotchedHomeScreen> {
  int _currentIndex = 1; // 預設在中間頁面

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('底部導航測試 - 凹陷效果'),
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
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          // 底部導航欄主體（帶凹陷）
          Container(
            height: 80,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: CustomPaint(
              painter: NotchedBottomNavPainter(),
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
                  // 中間空白區域（為凹陷留出空間）
                  const SizedBox(width: 80),
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
          ),
          // 中間浮動按鈕（突出於導航欄）
          Positioned(
            left: 0,
            right: 0,
            top: -10, // 讓按鈕向上突出
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = 1);
                  _showAddBeerDialog();
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
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
            const Text('新增啤酒功能測試 - 凹陷效果版本'),
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

// 自定義繪製器來創建帶凹陷的底部導航欄
class NotchedBottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    // 陰影繪製
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path();
    final shadowPath = Path();

    const radius = 20.0;
    const notchRadius = 32.0; // 凹陷半徑
    final notchCenter = size.width / 2;

    // 創建帶凹陷的路徑
    // 從左上角開始
    path.moveTo(radius, 0);

    // 上邊線到凹陷開始
    path.lineTo(notchCenter - notchRadius - 10, 0);

    // 創建凹陷（圓弧）
    path.quadraticBezierTo(
      notchCenter - notchRadius, 0,
      notchCenter - notchRadius, 10,
    );
    path.arcToPoint(
      Offset(notchCenter + notchRadius, 10),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      notchCenter + notchRadius, 0,
      notchCenter + notchRadius + 10, 0,
    );

    // 繼續上邊線到右上角
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // 右邊線
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // 下邊線
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // 左邊線
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // 複製路徑用於陰影
    shadowPath.addPath(path, const Offset(0, 2));

    // 繪製陰影
    canvas.drawPath(shadowPath, shadowPaint);

    // 繪製主體
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}