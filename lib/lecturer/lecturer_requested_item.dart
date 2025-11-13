import 'dart:convert';

import '../auth_storage.dart';
import '../config.dart';
import '../login.dart';
import 'lecturer_asset_list.dart';
import 'lecturer_history.dart';
import 'lecturer_home_page.dart';
import 'widgets/lecturer_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/lecturer_logout.dart';

class LecturerRequestedItem extends StatefulWidget {
  const LecturerRequestedItem({super.key});
  @override
  State<LecturerRequestedItem> createState() => _LecturerRequestedItemState();
}

class _LecturerRequestedItemState extends State<LecturerRequestedItem> {
  bool _isLoading = true;
  String? _error;
  List<PendingItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final userId = await AuthStorage.getUserId();
    if (!mounted) return;
    if (userId == null) {
      await AuthStorage.clearUserId();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _fetchPending();
      if (!mounted) return;
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
      });
    }
  }

  Future<List<PendingItem>> _fetchPending() async {
    final url = Uri.parse('${AppConfig.baseUrl}/requests/pending');
    final r = await http.get(url);
    if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}: ${r.body}');
    final List data = jsonDecode(r.body) as List;
    return data.map((e) => PendingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _approve(int requestId) async {
    final uid = await AuthStorage.getUserId();
    if (uid == null) return;
    final url = Uri.parse('${AppConfig.baseUrl}/requests/$requestId/approve');
    final r = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lecturerId': uid}));
    if (r.statusCode != 200) throw Exception(r.body);
  }

  Future<void> _reject(int requestId, String reason) async {
    final uid = await AuthStorage.getUserId();
    if (uid == null) return;
    final url = Uri.parse('${AppConfig.baseUrl}/requests/$requestId/reject');
    final r = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'lecturerId': uid, 'reason': reason}));
    if (r.statusCode != 200) throw Exception(r.body);
  }

  Future<void> _confirmApprove(PendingItem x) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ApproveDialog(item: x),
    );
    if (ok == true) {
      await _approve(x.requestId);
      if (!mounted) return;
      await _loadPending();
    }
  }

  Future<void> _confirmReject(PendingItem x) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason != null && reason.trim().isNotEmpty) {
      await _reject(x.requestId, reason.trim());
      if (!mounted) return;
      await _loadPending();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF1F1F1F);
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Assets',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: const [
          LecturerLogoutButton(iconColor: Colors.white),
        ],
      ),

      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: LecturerNavBar(
        index: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerHomePage()),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LecturerAssetList()),
            );
          } else if (i == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const LecturerHistory(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4FF00)));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPending,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No requests', style: TextStyle(color: Colors.white70)),
      );
    }

  String formatDate(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value.toLocal();
    } else if (value is String) {
      date = DateTime.tryParse(value)?.toLocal();
    }
    if (date == null) return '-';

    const month = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${month[date.month]} ${date.year % 100}';
  }
}

/* ------------ Model ------------ */

class PendingItem {
  final int requestId;
  final String assetName;
  final String? assetImage;
  final String borrowerName;
  final DateTime borrowDate;
  final DateTime returnDate;
  final String reason;

  PendingItem({
    required this.requestId,
    required this.assetName,
    required this.assetImage,
    required this.borrowerName,
    required this.borrowDate,
    required this.returnDate,
    required this.reason,
  });

  factory PendingItem.fromJson(Map<String, dynamic> j) => PendingItem(
        requestId: j['request_id'] as int,
        assetName: j['asset_name'] as String,
        assetImage: j['asset_image'] as String?,
        borrowerName: j['borrower_name'] as String,
        borrowDate: DateTime.parse(j['borrow_date'] as String),
        returnDate: DateTime.parse(j['return_date'] as String),
        reason: (j['reason'] as String?) ?? '-',
      );
}

/* ------------ Card ------------ */

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.item, required this.onApprove, required this.onReject});
  final PendingItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static const card = Color(0xFF3A3A3C);
  static const imgBg = Color(0xFF2C2C2E);

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) {
      const mon = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day.toString().padLeft(2, '0')} ${mon[d.month]} ${d.year % 100}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(28)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 110,
              height: 110,
              color: imgBg,
              child: (item.assetImage != null && item.assetImage!.isNotEmpty)
                  ? (item.assetImage!.startsWith('http')
                      ? Image.network(item.assetImage!, fit: BoxFit.cover)
                      : Image.asset('assets/images/${item.assetImage!}', fit: BoxFit.cover))
                  : const Icon(Icons.image, color: Colors.white24, size: 36),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _line('Item', item.assetName),
                _line('Borrower', item.borrowerName),
                _line('Borrow date', fmt(item.borrowDate)),
                _line('Return date', fmt(item.returnDate)),
                _line('Objective', item.reason.isEmpty ? '-' : item.reason),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _pillBtn(label: 'Approve', bg: const Color(0xFFDFFFAE), onTap: onApprove),
                    const SizedBox(width: 10),
                    _pillBtn(label: 'Reject', bg: const Color(0xFFF07A7A), onTap: onReject),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _line(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(text: '$k : ', style: const TextStyle(color: Colors.white70, fontSize: 15)),
            TextSpan(text: v, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ]),
        ),
      );

  static Widget _pillBtn({required String label, required Color bg, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/* ------------ Dialogs ------------ */

class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  String _selected = 'Unavailable on requested dates';
  final TextEditingController _other = TextEditingController();
  @override
  void dispose() { _other.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF2C2C2E),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rejected Requests',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._options.map((o) => RadioListTile<String>(
                  value: o,
                  groupValue: _selected,
                  onChanged: (v) => setState(() => _selected = v!),
                  activeColor: const Color(0xFFDFFFAE),
                  title: Text(o, style: const TextStyle(color: Colors.white)),
                )),
            RadioListTile<String>(
              value: 'Other',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              activeColor: const Color(0xFFDFFFAE),
              title: Row(
                children: [
                  const Text('Others  ', style: TextStyle(color: Colors.white)),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _other,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Reason',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn('Confirm', const Color(0xFFDFFFAE), () {
                  final reason = _selected == 'Other' ? _other.text.trim() : _selected;
                  Navigator.pop(context, reason);
                }),
                const SizedBox(width: 16),
                _actionBtn('Cancel', Colors.white24, () => Navigator.pop(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final _options = <String>[
    'Unavailable on requested dates',
    'Reserved for class or maintenance',
    'Invalid or incomplete request',
    'Temporarily under repair',
  ];

  static Widget _actionBtn(String t, Color c, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24)),
          child: Text(t, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
      );
}

class _ApproveDialog extends StatelessWidget {
  const _ApproveDialog({required this.item});
  final PendingItem item;

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) {
      const mon = ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day.toString().padLeft(2, '0')} ${mon[d.month]} ${d.year % 100}';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF2C2C2E),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Approved Requests',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(item.assetName, style: const TextStyle(color: Color(0xFFD4FF00), fontSize: 18)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF3A3A3C), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF2C2C2E),
                  child: (item.assetImage != null && item.assetImage!.isNotEmpty)
                      ? (item.assetImage!.startsWith('http')
                          ? Image.network(item.assetImage!, fit: BoxFit.cover)
                          : Image.asset('assets/images/${item.assetImage!}', fit: BoxFit.cover))
                      : const Icon(Icons.image, color: Colors.white24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _kv('Borrower', item.borrowerName),
                  _kv('Date', '${fmt(item.borrowDate)} → ${fmt(item.returnDate)}'),
                  _kv('Objective', item.reason.isEmpty ? '-' : item.reason),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _btn('Confirm', const Color(0xFFDFFFAE), () => Navigator.pop(context, true)),
            const SizedBox(width: 16),
            _btn('Cancel', Colors.white24, () => Navigator.pop(context, false)),
          ]),
        ]),
      ),
    );
  }

  static Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(text: '$k: ', style: const TextStyle(color: Colors.white70)),
            TextSpan(text: v, style: const TextStyle(color: Colors.white)),
          ]),
        ),
      );

  static Widget _btn(String t, Color c, VoidCallback onTap) => InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24)),
          child: Text(t, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        ),
      );
}
