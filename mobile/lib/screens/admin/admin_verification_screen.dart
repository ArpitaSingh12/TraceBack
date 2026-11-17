import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/document_download_button.dart';
import '../../widgets/verification_badge.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  String _filterStatus = 'All';
  List<DocumentItem> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loading = true);
    final documents = await ApiService.fetchAdminDocuments();
    if (!mounted) return;
    setState(() {
      _documents = documents;
      _loading = false;
    });
  }

  void _showReviewModal(DocumentItem doc) {
    final remarksCtrl = TextEditingController(text: doc.notes);
    bool isBusy = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.rule_folder_rounded, color: AppTheme.forestGreen, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Verifier Review Protocol',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 8),
                    _buildModalRow('Document Type', doc.documentType),
                    const SizedBox(height: 6),
                    _buildModalRow('Document Title', doc.title),
                    const SizedBox(height: 6),
                    _buildModalRow('File Name', doc.name),
                    const SizedBox(height: 6),
                    _buildModalRow('Uploaded By', doc.uploaderName),
                    const SizedBox(height: 6),
                    _buildModalRow('Submission Date', doc.date),
                    const SizedBox(height: 6),
                    _buildModalRow('Current Status', doc.status.toUpperCase()),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.creamDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.fingerprint, size: 16, color: AppTheme.mutedGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              doc.fileHash,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: AppTheme.charcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: remarksCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Verifier Audit Remarks & Findings',
                        hintText: 'Enter laboratory validation or inspection notes...',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.rejectedRed,
                              side: const BorderSide(color: AppTheme.rejectedRed),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: isBusy
                                ? null
                                : () async {
                                    setModalState(() => isBusy = true);
                                    final messenger = ScaffoldMessenger.of(context);
                                    final ok = await ApiService.verifyDocument(
                                      documentId: doc.id,
                                      status: 'rejected',
                                      remarks: remarksCtrl.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    if (ok) await _loadDocuments();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(ok ? 'Document rejected with remarks.' : 'Unable to reject document.'),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Reject'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.verifiedGreen,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: isBusy
                                ? null
                                : () async {
                                    setModalState(() => isBusy = true);
                                    final messenger = ScaffoldMessenger.of(context);
                                    final ok = await ApiService.verifyDocument(
                                      documentId: doc.id,
                                      status: 'verified',
                                      remarks: remarksCtrl.text.trim().isNotEmpty
                                          ? remarksCtrl.text.trim()
                                          : 'Verified and approved by Lead Compliance Auditor.',
                                    );
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    if (ok) await _loadDocuments();
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(ok ? 'Document verified & approved!' : 'Unable to verify document.'),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Approve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var documents = List<DocumentItem>.from(_documents);

    if (_filterStatus != 'All') {
      documents = documents.where((d) => d.status.toLowerCase() == _filterStatus.toLowerCase()).toList();
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDocuments,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verification Queue', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${documents.length} certificates requiring compliance validation.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: ['All', 'pending', 'verified', 'rejected'].map((status) {
                final isSelected = _filterStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      status == 'All'
                          ? 'All (${_documents.length})'
                          : '${status[0].toUpperCase()}${status.substring(1)} (${_documents.where((d) => d.status.toLowerCase() == status.toLowerCase()).length})',
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _filterStatus = status),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ...documents.map((doc) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.verified_outlined, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doc.documentType,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          VerificationBadge(status: doc.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        doc.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${doc.name} • Product: ${doc.productName}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppTheme.mutedGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doc.notes,
                        style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploaded by: ${doc.uploaderName}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                          ),
                          Text(
                            doc.date,
                            style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DocumentDownloadButton(document: doc),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => _showReviewModal(doc),
                            icon: const Icon(Icons.rate_review_outlined, size: 16),
                            label: const Text('Review & Verify'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
