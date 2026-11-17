import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/demo_data.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/demo_banner.dart';

class AddProductModal extends StatefulWidget {
  final VoidCallback onProductCreated;

  const AddProductModal({super.key, required this.onProductCreated});

  static void show(BuildContext context, VoidCallback onProductCreated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProductModal(onProductCreated: onProductCreated),
    );
  }

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController(text: 'Aster Flow Organics');
  final _originCtrl = TextEditingController(text: 'Wayanad, Kerala, India');
  final _batchCtrl = TextEditingController(text: 'AFO-2024-NEW-01');
  final _descCtrl = TextEditingController();

  PlatformFile? _selectedImage;
  String _category = 'Honey';
  DateTime _mfgDate = DateTime.now().subtract(const Duration(days: 15));
  DateTime _expDate = DateTime.now().add(const Duration(days: 365));
  bool _busy = false;
  double? _uploadProgress;

  final List<String> _categories = [
    'Honey',
    'Coffee',
    'Spices',
    'Tea',
    'Oils',
    'Dairy & Ghee',
    'Salt & Minerals',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newProduct = Product(
      id: 0,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : 'TraceBack certified food item with documented farm origin and blockchain batch sealing.',
      category: _category,
      brand: _brandCtrl.text.trim(),
      origin: _originCtrl.text.trim(),
      status: 'In Production',
      transparencyScore: 85,
      imageUrl: '',
      batchNumber: _batchCtrl.text.trim(),
      manufacturingDate: _mfgDate.toIso8601String().split('T').first,
      expiryDate: _expDate.toIso8601String().split('T').first,
      producerId: 1,
      producerName: _brandCtrl.text.trim(),
      ingredients: ['100% Organically Sourced'],
      isDemo: false,
      isVerified: false,
    );

    setState(() {
      _busy = true;
      _uploadProgress = _selectedImage == null ? null : 0;
    });

    final productId = await ApiService.createProduct(newProduct);
    if (!mounted) return;
    if (productId == null) {
      setState(() {
        _busy = false;
        _uploadProgress = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to create product. Check the connection and try again.')),
      );
      return;
    }

    var imageUploaded = true;
    if (_selectedImage != null) {
      imageUploaded = await ApiService.uploadProductImage(
        productId: productId,
        image: _selectedImage!,
        onProgress: (progress) {
          if (mounted) setState(() => _uploadProgress = progress);
        },
      );
    }
    if (!mounted) return;
    widget.onProductCreated();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          imageUploaded
              ? 'Product added successfully!'
              : 'Product created, but its image upload failed. Edit the product to retry.',
        ),
      ),
    );
  }

  Future<void> _pickProductImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.size > 10 * 1024 * 1024 || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a readable image smaller than 10 MB.')),
      );
      return;
    }
    setState(() => _selectedImage = file);
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
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
              const DemoBanner(label: 'Creates product record and associates batch manifest'),
              Text(
                'Register New Product',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. Cardamom Honey, Black Robusta...',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) => setState(() => _category = val ?? 'Honey'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(labelText: 'Brand / Estate'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _originCtrl,
                decoration: const InputDecoration(labelText: 'Origin Location'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _batchCtrl,
                decoration: const InputDecoration(labelText: 'Initial Batch Identifier'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _mfgDate,
                          firstDate: DateTime(2022),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _mfgDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: Text(
                        'Mfg: ${_mfgDate.toIso8601String().split('T').first}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) setState(() => _expDate = picked);
                      },
                      icon: const Icon(Icons.event, size: 14),
                      label: Text(
                        'Exp: ${_expDate.toIso8601String().split('T').first}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Product Description & Sourcing Story',
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImage!.bytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImage!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                ),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pickProductImage,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(_selectedImage == null ? 'Select Product Photo' : 'Replace Photo'),
                    ),
                  ),
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Remove selected photo',
                      onPressed: _busy ? null : () => setState(() => _selectedImage = null),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ],
              ),
              if (_uploadProgress != null) ...[
                const SizedBox(height: 6),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 4),
                Text(
                  'Uploading photo: ${(_uploadProgress! * 100).round()}%',
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Product'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddBatchModal extends StatefulWidget {
  final VoidCallback onBatchCreated;

  const AddBatchModal({super.key, required this.onBatchCreated});

  static void show(BuildContext context, VoidCallback onBatchCreated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBatchModal(onBatchCreated: onBatchCreated),
    );
  }

  @override
  State<AddBatchModal> createState() => _AddBatchModalState();
}

class _AddBatchModalState extends State<AddBatchModal> {
  final _formKey = GlobalKey<FormState>();
  final _batchCtrl = TextEditingController(text: 'BAT-2024-V92');
  late Product _selectedProduct;

  @override
  void initState() {
    super.initState();
    _selectedProduct = DemoData.getProducts().first;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newBatch = BatchRecord(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      productId: _selectedProduct.id,
      productName: _selectedProduct.name,
      batchNumber: _batchCtrl.text.trim(),
      qrCode: 'tb://qr/batch/${_selectedProduct.id}/${_batchCtrl.text.trim()}',
      createdAt: DateTime.now().toIso8601String().split('T').first,
      status: 'Batch Initialized',
      totalEvents: 1,
    );

    DemoData.addBatch(newBatch);
    widget.onBatchCreated();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Batch created and QR code generated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = DemoData.getProducts();

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
      child: Form(
        key: _formKey,
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
            Text('Create Production Batch', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            DropdownButtonFormField<Product>(
              value: _selectedProduct,
              decoration: const InputDecoration(labelText: 'Select Product'),
              items: products
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedProduct = val);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _batchCtrl,
              decoration: const InputDecoration(
                labelText: 'Batch Number',
                hintText: 'e.g. FBH-2024-102',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('Generate Batch'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddJourneyEventModal extends StatefulWidget {
  final VoidCallback onEventCreated;

  const AddJourneyEventModal({super.key, required this.onEventCreated});

  static void show(BuildContext context, VoidCallback onEventCreated) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddJourneyEventModal(onEventCreated: onEventCreated),
    );
  }

  @override
  State<AddJourneyEventModal> createState() => _AddJourneyEventModalState();
}

class _AddJourneyEventModalState extends State<AddJourneyEventModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController(text: 'Cold Processing & Testing');
  final _locationCtrl = TextEditingController(text: 'Wayanad Processing Plant');
  final _orgCtrl = TextEditingController(text: 'Aster Flow Quality Guild');
  final _descCtrl = TextEditingController(text: 'Moisture and purity analysis verified without heating.');
  String _eventType = 'Processing';

  final List<String> _types = [
    'Harvest',
    'Processing',
    'Quality Analysis',
    'Packaging',
    'Cold Transit',
    'Distribution',
  ];

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newEvent = SupplyEvent(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      batchId: 1,
      title: _titleCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      date: DateTime.now().toIso8601String().split('T').first,
      organization: _orgCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      eventType: _eventType,
      isVerified: true,
    );

    DemoData.addJourneyEvent(newEvent);
    widget.onEventCreated();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Supply-chain milestone recorded!')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
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
              Text('Log Supply-Chain Milestone', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _eventType = v ?? 'Processing'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Location / Facility'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orgCtrl,
                decoration: const InputDecoration(labelText: 'Responsible Organization'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description / Audit Observations'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: const Text('Save Event'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadDocumentModal extends StatefulWidget {
  final VoidCallback onDocumentUploaded;

  const UploadDocumentModal({super.key, required this.onDocumentUploaded});

  static void show(BuildContext context, VoidCallback onDocumentUploaded) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadDocumentModal(onDocumentUploaded: onDocumentUploaded),
    );
  }

  @override
  State<UploadDocumentModal> createState() => _UploadDocumentModalState();
}

class _UploadDocumentModalState extends State<UploadDocumentModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  List<Product> _products = [];
  Product? _selectedProduct;
  PlatformFile? _selectedFile;
  String _docType = 'Lab Test Report';
  bool _loadingProducts = true;
  bool _busy = false;
  double? _uploadProgress;

  final List<String> _types = [
    'Organic Certification',
    'Lab Test Report',
    'GI Tag Registration',
    'Sustainability Audit',
    'FSSAI License Document',
    'Fair Trade Certificate',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await ApiService.fetchMyProducts();
    if (!mounted) return;
    setState(() {
      _products = products;
      _selectedProduct = products.isEmpty ? null : products.first;
      _loadingProducts = false;
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.size > 20 * 1024 * 1024 || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a readable PDF, JPG or PNG smaller than 20 MB.')),
      );
      return;
    }
    setState(() => _selectedFile = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a product and choose a document file.')),
      );
      return;
    }

    setState(() {
      _busy = true;
      _uploadProgress = 0;
    });
    final uploaded = await ApiService.uploadDocument(
      productId: _selectedProduct!.id,
      title: _titleCtrl.text.trim(),
      documentType: _docType,
      file: _selectedFile!,
      onProgress: (progress) {
        if (mounted) setState(() => _uploadProgress = progress);
      },
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!uploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document upload failed. Check the file and try again.')),
      );
      return;
    }
    widget.onDocumentUploaded();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document uploaded and queued as pending verification.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: Form(
          key: _formKey,
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
              Text('Upload Verification Document', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Document Title'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _docType,
                decoration: const InputDecoration(labelText: 'Document Type'),
                items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: _busy ? null : (value) => setState(() => _docType = value ?? 'Lab Test Report'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Product>(
                value: _selectedProduct,
                decoration: const InputDecoration(labelText: 'Related Product'),
                items: _products
                    .map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(product.name, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: _busy
                    ? null
                    : (product) => setState(() => _selectedProduct = product),
                hint: Text(_loadingProducts ? 'Loading products...' : 'No producer products available'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : _pickDocument,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Choose PDF or image document' : 'Replace document'),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 6),
                Text(
                  _selectedFile!.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
              if (_uploadProgress != null) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 4),
                Text(
                  'Uploading: ${(_uploadProgress! * 100).round()}%',
                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || _loadingProducts || _products.isEmpty ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Upload Document'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
