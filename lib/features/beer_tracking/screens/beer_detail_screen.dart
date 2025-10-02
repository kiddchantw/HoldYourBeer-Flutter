import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/themes/beer_colors.dart';
import '../providers/tasting_provider.dart';
import '../data/tasting_api_client.dart';

// 飲酒記錄模型
class TastingRecord {
  final String id;
  final DateTime timestamp;
  final String action; // 'add' or 'remove'
  final String? note;

  TastingRecord({
    required this.id,
    required this.timestamp,
    required this.action,
    this.note,
  });
}

// 啤酒詳細資訊模型
class BeerDetail {
  final String id;
  final String brand;
  final String name;
  final List<TastingRecord> records;

  BeerDetail({
    required this.id,
    required this.brand,
    required this.name,
    required this.records,
  });
}

// 啤酒詳細頁面
class BeerDetailScreen extends ConsumerStatefulWidget {
  final String beerId;
  final String brand;
  final String name;

  const BeerDetailScreen({
    super.key,
    required this.beerId,
    required this.brand,
    required this.name,
  });

  @override
  ConsumerState<BeerDetailScreen> createState() => _BeerDetailScreenState();
}

class _BeerDetailScreenState extends ConsumerState<BeerDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  // 模擬資料
  late List<TastingRecord> records;

  @override
  void initState() {
    super.initState();
    // 模擬歷史記錄資料
    records = [
      TastingRecord(
        id: '1',
        timestamp: DateTime.parse('2025-09-19T02:02:09.000000Z'),
        action: 'add',
        note: null,
      ),
      TastingRecord(
        id: '2',
        timestamp: DateTime.parse('2025-08-21T19:35:58.000000Z'),
        action: 'add',
        note: 'MIT',
      ),
      TastingRecord(
        id: '3',
        timestamp: DateTime.parse('2025-08-21T19:29:49.000000Z'),
        action: 'remove',
        note: null,
      ),
    ];
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _addTastingNote() {
    final note = _noteController.text.trim();
    if (note.isNotEmpty && note.length <= 150) {
      final newRecord = TastingRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        action: 'add',
        note: note,
      );

      setState(() {
        records.insert(0, newRecord);
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('品嚐記錄已新增'),
          duration: Duration(seconds: 2),
        ),
      );

      _noteFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brand} ${widget.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 歷史記錄列表
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Text(
                      '尚無飲酒記錄',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isAdd = record.action == 'add';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 操作圖示
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isAdd ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAdd ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 記錄內容
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 時間戳記
                                  Text(
                                    record.timestamp.toIso8601String(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  // 品嚐記錄
                                  if (record.note != null && record.note!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        record.note!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // 品嚐記錄輸入區域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '品嚐記錄 (選填)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  focusNode: _noteFocusNode,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: '輸入品嚐記錄...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: BeerColors.primaryAmber500),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addTastingNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BeerColors.primaryAmber500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '新增品嚐記錄',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}