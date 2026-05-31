import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_branding.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/report_file_service.dart';
import '../../../../domain/entities/report_entity.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static (DateTime start, DateTime end) periodForPreset(String preset) {
    final now = DateTime.now();
    switch (preset) {
      case 'last_month':
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59, 999);
        return (start, end);
      case 'last_3_months':
        final start = DateTime(now.year, now.month - 2, 1);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return (start, end);
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return (start, end);
    }
  }

  Future<void> _showGenerateSheet(BuildContext context, WidgetRef ref) async {
    var type = ReportType.summary;
    var preset = 'this_month';
    var busy = false;

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final (start, end) = periodForPreset(preset);
            final periodLabel =
                '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Generate report',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Text('Report type', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<ReportType>(
                    segments: [
                      for (final t in ReportType.values)
                        ButtonSegment(value: t, label: Text(t.label, textAlign: TextAlign.center)),
                    ],
                    selected: {type},
                    onSelectionChanged: busy
                        ? null
                        : (value) => setState(() => type = value.first),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: preset,
                    decoration: const InputDecoration(labelText: 'Period'),
                    items: const [
                      DropdownMenuItem(value: 'this_month', child: Text('This month')),
                      DropdownMenuItem(value: 'last_month', child: Text('Last month')),
                      DropdownMenuItem(value: 'last_3_months', child: Text('Last 3 months')),
                    ],
                    onChanged: busy ? null : (v) => setState(() => preset = v ?? preset),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    periodLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            setState(() => busy = true);
                            final report = await ref.read(reportsProvider.notifier).generate(
                                  type: type,
                                  periodStart: start,
                                  periodEnd: end,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              if (report != null) {
                                context.push(AppRoutes.reportView, extra: report);
                              }
                            }
                          },
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.description_outlined),
                    label: Text(busy ? 'Generating…' : 'Generate CSV report'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGenerateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New report'),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load reports: $e')),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assessment_outlined, size: 64, color: Colors.black.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'No reports yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Generate a CSV summary or transaction report for any period. '
                      'View it here and download or share it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _showGenerateSheet(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Generate your first report'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    child: Icon(
                      report.type == ReportType.summary ? Icons.summarize_outlined : Icons.receipt_long_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Created ${DateFormat('d MMM yyyy, HH:mm').format(report.createdAt)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.reportView, extra: report),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReportViewScreen extends ConsumerStatefulWidget {
  const ReportViewScreen({super.key, required this.report});

  final ReportEntity report;

  @override
  ConsumerState<ReportViewScreen> createState() => _ReportViewScreenState();
}

class _ReportViewScreenState extends ConsumerState<ReportViewScreen> {
  String? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final text = await ReportFileService.read(widget.report.fileName);
    if (mounted) {
      setState(() {
        _content = text;
        _loading = false;
      });
    }
  }

  Future<void> _share() async {
    final file = await ReportFileService.fileFor(widget.report.fileName);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report file not found.')),
        );
      }
      return;
    }
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: widget.report.fileName)],
      subject: '${AppBranding.appName} report',
      text: widget.report.title,
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This removes the report from your device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(reportsProvider.notifier).deleteReport(widget.report);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View report'),
        actions: [
          IconButton(
            tooltip: 'Download / share',
            onPressed: _loading ? null : _share,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: _loading ? null : _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.report.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.report.type.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E4EA)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _content ?? '',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.45),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: FilledButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Download / share CSV'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
