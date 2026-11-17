import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';
import '../../widgets/document_download_button.dart';
import '../../widgets/verification_badge.dart';
import 'producer_forms.dart';

class ProducerDocumentsScreen extends StatefulWidget {
  const ProducerDocumentsScreen({super.key});

  @override
  State<ProducerDocumentsScreen> createState() => _ProducerDocumentsScreenState();
}

class _ProducerDocumentsScreenState extends State<ProducerDocumentsScreen> {
  List<DocumentItem> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loading = true);
    final documents = await ApiService.fetchMyDocuments();
    if (!mounted) return;
    setState(() {
      _documents = documents;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final documents = _documents;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () => UploadDocumentModal.show(context, _loadDocuments),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Document'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDocuments,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
          children: [
            const DemoBanner(label: 'Certificates & Lab Reports • Verification Audit Vault'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supporting Documents', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${documents.length} certificates and test assays attached to products.',
                      style: const TextStyle(fontSize: 13, color: AppTheme.mutedGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (documents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No submitted documents yet.')),
              )
            else
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
                                const Icon(Icons.description_outlined, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    doc.title,
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
                        '${doc.documentType} • ${doc.productName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doc.name,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppTheme.mutedGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doc.notes,
                        style: const TextStyle(fontSize: 12, color: AppTheme.charcoalLight),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.creamDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.fingerprint, size: 14, color: AppTheme.mutedGrey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                doc.fileHash,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: AppTheme.mutedGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 10),
                      DocumentDownloadButton(document: doc),
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
