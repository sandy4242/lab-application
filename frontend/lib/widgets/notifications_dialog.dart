import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/mock_data_service.dart';
import 'package:intl/intl.dart';

class NotificationsDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _NotificationsListDialog(),
    );
  }
}

class _NotificationsListDialog extends StatefulWidget {
  const _NotificationsListDialog();

  @override
  State<_NotificationsListDialog> createState() => _NotificationsListDialogState();
}

class _NotificationsListDialogState extends State<_NotificationsListDialog> {
  final MockDataService _dataService = MockDataService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId ?? 'user-student-1';
    final notes = _dataService.getNotifications(userId);
    setState(() {
      _notifications = notes;
      _isLoading = false;
    });
  }

  void _markAsRead(String id) {
    _dataService.markNotificationAsRead(id);
    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.teal),
          SizedBox(width: 10),
          Text('My Notifications'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 350,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (c, index) {
                      final note = _notifications[index];
                      final id = note['id'];
                      final title = note['title'] ?? 'Notification';
                      final message = note['message'] ?? '';
                      final isRead = note['is_read'] as bool? ?? false;
                      final dateRaw = note['created_at'];
                      
                      String date = '';
                      try {
                        date = DateFormat.jm().add_yMMMd().format(DateTime.parse(dateRaw));
                      } catch (_) {}

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            if (!isRead)
                              const Padding(
                                padding: EdgeInsets.only(right: 6.0),
                                child: Icon(Icons.fiber_new, color: Colors.red, size: 24),
                              ),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(message, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        trailing: !isRead
                            ? IconButton(
                                icon: const Icon(Icons.done, size: 18, color: Colors.teal),
                                tooltip: 'Mark as read',
                                onPressed: () => _markAsRead(id),
                              )
                            : const Icon(Icons.done_all, size: 18, color: Colors.grey),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
