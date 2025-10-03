import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/themes/beer_colors.dart';
import '../providers/tasting_provider.dart';
import '../../../core/utils/date_time_utils.dart';

// 啤酒詳細頁面 (使用真實 API)
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
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addTastingNote() async {
    final note = _noteController.text.trim();
    if (note.isEmpty || note.length > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('品嚐記錄不能為空且不能超過150字元'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final beerId = int.parse(widget.beerId);
      await ref.read(tastingActionsProvider).addTastingRecord(beerId, note);

      _noteController.clear();
      _noteFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('品嚐記錄已新增'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('新增失敗: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final beerId = int.parse(widget.beerId);
    final tastingLogsAsync = ref.watch(tastingLogsProvider(beerId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brand} ${widget.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tastingLogsProvider(beerId));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 歷史記錄列表
            Expanded(
              child: tastingLogsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '載入失敗: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(tastingLogsProvider(beerId)),
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                ),
                data: (tastingLogs) {
                  if (tastingLogs.isEmpty) {
                    return const Center(
                      child: Text(
                        '尚無飲酒記錄',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: tastingLogs.length,
                    itemBuilder: (context, index) {
                      final record = tastingLogs[index];
                      final isAdd = record.action == 'increment';

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
                                    DateTimeUtils.formatUserFriendly(record.tastedAt),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  // 詳細時間（小字）
                                  Text(
                                    DateTimeUtils.formatRelative(record.tastedAt),
                                    style: const TextStyle(
                                      fontSize: 12,
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
                  );
                },
              ),
            ),
            // 分隔線
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey[300],
            ),
            // 品嚐記錄輸入區域
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
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
                    enabled: !_isLoading,
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
                      onPressed: _isLoading ? null : _addTastingNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BeerColors.primaryAmber500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
      ),
    );
  }
}