class UserRoleHelper {
  static String normalize(String? role) {
    final value = (role ?? '').trim().toLowerCase();

    if (value.isEmpty) {
      return 'customer';
    }

    if (['admin', 'administrator', 'verifier', 'staff', 'super_admin'].contains(value)) {
      return 'admin';
    }

    if (['producer', 'supplier', 'manufacturer', 'farmer'].contains(value)) {
      return 'producer';
    }

    return 'customer';
  }

  static String displayName(String role) {
    switch (normalize(role)) {
      case 'admin':
        return 'Admin / Verifier';
      case 'producer':
        return 'Producer';
      default:
        return 'Customer';
    }
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String location;
  final String organization;
  final String memberSince;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '+91 98765 43210',
    this.location = 'Bengaluru, India',
    this.organization = 'TraceBack Network',
    this.memberSince = 'Jan 2024',
    this.avatarUrl = '',
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? location,
    String? organization,
    String? memberSince,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      organization: organization ?? this.organization,
      memberSince: memberSince ?? this.memberSince,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: UserRoleHelper.normalize(json['role'] as String?),
        phone: json['phone'] ?? '+91 98765 43210',
        location: json['location'] ?? 'Karnataka, India',
        organization: json['organization'] ?? 'TraceBack',
        memberSince: json['created_at'] != null
            ? json['created_at'].toString().split('T').first
            : 'Jan 2024',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'location': location,
        'organization': organization,
        'member_since': memberSince,
      };
}

class Product {
  final int id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final String origin;
  final String status;
  final int transparencyScore;
  final String imageUrl;
  final String batchNumber;
  final String manufacturingDate;
  final String expiryDate;
  final int producerId;
  final String producerName;
  final List<String> ingredients;
  final bool isDemo;
  final bool isVerified;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.origin,
    required this.status,
    required this.transparencyScore,
    required this.imageUrl,
    required this.batchNumber,
    this.manufacturingDate = '2024-11-01',
    this.expiryDate = '2025-11-01',
    this.producerId = 1,
    this.producerName = 'TraceBack Certified',
    this.ingredients = const [],
    this.isDemo = false,
    this.isVerified = true,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    String? brand,
    String? origin,
    String? status,
    int? transparencyScore,
    String? imageUrl,
    String? batchNumber,
    String? manufacturingDate,
    String? expiryDate,
    int? producerId,
    String? producerName,
    List<String>? ingredients,
    bool? isDemo,
    bool? isVerified,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      origin: origin ?? this.origin,
      status: status ?? this.status,
      transparencyScore: transparencyScore ?? this.transparencyScore,
      imageUrl: imageUrl ?? this.imageUrl,
      batchNumber: batchNumber ?? this.batchNumber,
      manufacturingDate: manufacturingDate ?? this.manufacturingDate,
      expiryDate: expiryDate ?? this.expiryDate,
      producerId: producerId ?? this.producerId,
      producerName: producerName ?? this.producerName,
      ingredients: ingredients ?? this.ingredients,
      isDemo: isDemo ?? this.isDemo,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json, {bool isDemo = false}) => Product(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown product',
        description: json['description'] ?? 'No description available.',
        category: json['category'] ?? 'General',
        brand: json['brand'] ?? 'TraceBack',
        origin: json['origin_location'] ?? json['origin'] ?? 'Origin not specified',
        status: json['current_status'] ?? json['status'] ?? 'In production',
        transparencyScore: json['transparency_score'] ?? 0,
        imageUrl: json['image_url'] ?? '',
        batchNumber: json['batch_number'] ?? 'N/A',
        manufacturingDate: json['manufacturing_date']?.toString() ?? '2024-10-15',
        expiryDate: json['expiry_date']?.toString() ?? '2025-10-15',
        producerId: json['producer_id'] ?? 1,
        producerName: json['brand'] ?? 'Producer',
        isDemo: isDemo,
        isVerified: (json['transparency_score'] ?? 0) >= 80,
      );
}

class SupplyEvent {
  final int id;
  final int batchId;
  final String title;
  final String location;
  final String date;
  final String organization;
  final String description;
  final String eventType;
  final String? supportingDocument;
  final bool isVerified;

  SupplyEvent({
    this.id = 0,
    this.batchId = 0,
    required this.title,
    required this.location,
    required this.date,
    required this.organization,
    required this.description,
    this.eventType = 'Milestone',
    this.supportingDocument,
    this.isVerified = true,
  });

  factory SupplyEvent.fromJson(Map<String, dynamic> json) => SupplyEvent(
        id: json['id'] ?? 0,
        batchId: json['batch_id'] ?? 0,
        title: json['event_type'] ?? 'Journey Event',
        location: json['location'] ?? 'Unknown location',
        date: json['event_date']?.toString() ?? '',
        organization: json['organization'] ?? 'Unknown organization',
        description: json['description'] ?? '',
        eventType: json['event_type'] ?? 'General',
        supportingDocument: json['supporting_document'],
        isVerified: true,
      );
}

class DocumentItem {
  final int id;
  final int productId;
  final String productName;
  final String title;
  final String name;
  final String status; // 'verified', 'pending', 'rejected'
  final String notes;
  final String documentType;
  final String fileHash;
  final String uploaderName;
  final String date;
  final bool isDemo;

  DocumentItem({
    required this.id,
    this.productId = 0,
    this.productName = '',
    this.title = '',
    required this.name,
    required this.status,
    required this.notes,
    this.documentType = 'Certificate',
    this.fileHash = 'SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069',
    this.uploaderName = 'Certified Producer',
    this.date = '2024-11-10',
    this.isDemo = false,
  });

  DocumentItem copyWith({
    int? id,
    int? productId,
    String? productName,
    String? title,
    String? name,
    String? status,
    String? notes,
    String? documentType,
    String? fileHash,
    String? uploaderName,
    String? date,
    bool? isDemo,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      title: title ?? this.title,
      name: name ?? this.name,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      documentType: documentType ?? this.documentType,
      fileHash: fileHash ?? this.fileHash,
      uploaderName: uploaderName ?? this.uploaderName,
      date: date ?? this.date,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  factory DocumentItem.fromJson(Map<String, dynamic> json, {bool isDemo = false}) => DocumentItem(
        id: json['id'] ?? 0,
        productId: json['product_id'] ?? 0,
        productName: json['product_name'] ?? '',
        title: json['title'] ?? json['file_name'] ?? 'Document',
        name: json['file_name'] ?? 'Document',
        status: (json['status'] ?? 'pending').toString().toLowerCase(),
        notes: json['verifier_remarks'] ?? 'Pending review',
        documentType: json['document_type'] ?? 'Supporting Document',
        fileHash: json['file_hash'] ?? 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        uploaderName: json['uploader_name'] ?? 'Producer',
        date: json['created_at'] != null
            ? json['created_at'].toString().split('T').first
            : '2024-11-10',
        isDemo: isDemo,
      );
}

class BatchRecord {
  final int id;
  final int productId;
  final String productName;
  final String batchNumber;
  final String qrCode;
  final String createdAt;
  final String status;
  final int totalEvents;

  BatchRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.batchNumber,
    required this.qrCode,
    required this.createdAt,
    this.status = 'In transit',
    this.totalEvents = 4,
  });

  factory BatchRecord.fromJson(Map<String, dynamic> json) => BatchRecord(
        id: json['id'] ?? 0,
        productId: json['product_id'] ?? 0,
        productName: json['product_name'] ?? 'Product Batch',
        batchNumber: json['batch_number'] ?? 'N/A',
        qrCode: json['qr_code'] ?? '',
        createdAt: json['created_at'] != null
            ? json['created_at'].toString().split('T').first
            : '2024-11-01',
        status: json['status'] ?? 'Active',
      );
}

class UserRecord {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String createdAt;
  final String organization;

  UserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.status = 'Active',
    this.createdAt = '2024-10-01',
    this.organization = 'TraceBack Network',
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) => UserRecord(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: UserRoleHelper.normalize(json['role'] as String?),
        status: 'Active',
        createdAt: json['created_at'] != null
            ? json['created_at'].toString().split('T').first
            : '2024-10-01',
        organization: json['organization'] ?? 'TraceBack',
      );
}

class ActivityRecord {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final String type; // 'verify', 'create', 'update', 'scan'

  ActivityRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });
}
