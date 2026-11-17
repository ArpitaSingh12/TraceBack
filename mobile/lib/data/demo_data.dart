import '../models/models.dart';

class DemoProducer {
  final int id;
  final String name;
  final String location;
  final String description;
  final String foundedYear;
  final String certifications;
  final String logoUrl;
  final int productCount;
  final double rating;

  const DemoProducer({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.foundedYear,
    required this.certifications,
    required this.logoUrl,
    required this.productCount,
    this.rating = 4.9,
  });
}

class DemoData {
  // 8 Realistic Producers
  static final List<DemoProducer> producers = [
    const DemoProducer(
      id: 1,
      name: 'Aster Flow Organics',
      location: 'Kashmir Valley & Nilgiris, India',
      description: 'Pioneers in pesticide-free, wild-harvested apiaries and alpine herb farming.',
      foundedYear: '2016',
      certifications: 'India Organic, USDA Organic, Fair Trade Certified',
      logoUrl: 'assets/images/wildflower_honey.jpg',
      productCount: 14,
    ),
    const DemoProducer(
      id: 2,
      name: 'Green Valley Cooperative',
      location: 'Gir & Saurashtra, Gujarat, India',
      description: 'A 450-member smallholder collective specializing in cold-pressed indigenous oils and A2 dairy.',
      foundedYear: '2012',
      certifications: 'NPOP Organic, FSSAI Golden Standard, Non-GMO',
      logoUrl: 'https://images.unsplash.com/photo-1500595046743-cd271d694d30',
      productCount: 22,
    ),
    const DemoProducer(
      id: 3,
      name: 'Himalayan Harvest Farms',
      location: 'Ranikhet & Almora, Uttarakhand, India',
      description: 'High-altitude terraced farming cultivating ancestral spice varieties and rock minerals.',
      foundedYear: '2018',
      certifications: 'Uttarakhand Organic Certified, ISO 22000',
      logoUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
      productCount: 11,
    ),
    const DemoProducer(
      id: 4,
      name: 'Sunrise Estate Coffee',
      location: 'Coorg, Karnataka, India',
      description: 'Four generations of shade-grown, rain-fed single-estate Arabica and Robusta plantations.',
      foundedYear: '1978',
      certifications: 'Rainforest Alliance, Bird Friendly, Specialty Coffee Guild',
      logoUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e',
      productCount: 9,
    ),
    const DemoProducer(
      id: 5,
      name: 'Western Ghats Naturals',
      location: 'Idukki & Wayanad, Kerala, India',
      description: 'Dedicated to native biodiversity spice conservation and regenerative forest farming.',
      foundedYear: '2015',
      certifications: 'Spice Board India Organic, Fair For Life',
      logoUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
      productCount: 18,
    ),
    const DemoProducer(
      id: 6,
      name: 'Coorg Mountain Producers',
      location: 'Madikeri, Coorg, Karnataka, India',
      description: 'Estate coffee & black pepper guild maintaining high elevation biodiversity canopies.',
      foundedYear: '2004',
      certifications: 'Geographical Indication (GI) Coorg, UTZ Certified',
      logoUrl: 'https://images.unsplash.com/photo-1518495973542-4542c06a5843',
      productCount: 8,
    ),
    const DemoProducer(
      id: 7,
      name: 'Wayanad Spice Collective',
      location: 'Sulthan Bathery, Wayanad, Kerala, India',
      description: 'Tribal and smallholder grower alliance producing sun-cured Tellicherry and Malabar spices.',
      foundedYear: '2011',
      certifications: 'NPOP, Participatory Guarantee System (PGS-India)',
      logoUrl: 'assets/images/ceylon_cinnamon.jpg',
      productCount: 16,
    ),
    const DemoProducer(
      id: 8,
      name: 'Darjeeling Heritage Estates',
      location: 'Kurseong & Darjeeling, West Bengal, India',
      description: 'High-elevation Himalayan tea gardens producing organic first flush and muscatel teas.',
      foundedYear: '1892',
      certifications: 'GI Darjeeling, Demeter Biodynamic, Fairtrade',
      logoUrl: 'assets/images/darjeeling_tea.jpg',
      productCount: 12,
    ),
  ];

  // 12 Products as specified in requirements
  static final List<Product> initialProducts = [
    Product(
      id: 1,
      name: 'Forest Bloom Wildflower Honey',
      description: 'Raw, unpasteurized honey hand-harvested from native flora belts in the Nilgiris and Wayanad reserves. Retains natural propolis, pollen grains, and enzymatic vitality without heat processing.',
      category: 'Honey',
      brand: 'Aster Flow Organics',
      origin: 'Nilgiris & Wayanad, Kerala, India',
      status: 'Verified & Distributed',
      transparencyScore: 94,
      imageUrl: 'assets/images/wildflower_honey.jpg',
      batchNumber: 'FBH-2024-089-A',
      manufacturingDate: '2024-09-12',
      expiryDate: '2026-09-12',
      producerId: 1,
      producerName: 'Aster Flow Organics',
      ingredients: ['100% Pure Raw Wildflower Blossom Honey'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 2,
      name: 'Coorg Arabica Coffee',
      description: 'Shade-grown under silver oak, fig, and rosewood canopies at 1,200m elevation. Hand-picked ripe red cherries, fermented for 24 hours, washed with fresh mountain stream water, and patio dried.',
      category: 'Coffee',
      brand: 'Sunrise Estate Coffee',
      origin: 'Madikeri, Coorg, Karnataka, India',
      status: 'Verified & In Market',
      transparencyScore: 92,
      imageUrl: 'assets/images/coorg_arabica_coffee.jpg',
      batchNumber: 'CO-ARB-2024-041',
      manufacturingDate: '2024-10-05',
      expiryDate: '2025-10-05',
      producerId: 4,
      producerName: 'Sunrise Estate Coffee',
      ingredients: ['100% Specialty Grade Arabica Whole Beans (SLN 79.5 & Selection 9)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 3,
      name: 'Himalayan Turmeric Powder',
      description: 'Cultivated in mineral-dense high-altitude soil of Ranikhet. Boasts an exceptional 6.8% natural curcumin content. Cold-ground using traditional stone mill techniques to protect volatile essential oils.',
      category: 'Spices',
      brand: 'Himalayan Harvest Farms',
      origin: 'Ranikhet, Uttarakhand, India',
      status: 'Verified & Batch Sealed',
      transparencyScore: 96,
      imageUrl: 'assets/images/himalayan_turmeric.jpg',
      batchNumber: 'HTP-8823-C',
      manufacturingDate: '2024-08-20',
      expiryDate: '2026-08-20',
      producerId: 3,
      producerName: 'Himalayan Harvest Farms',
      ingredients: ['100% Organic Himalayan Lakadong-lineage Turmeric Rhizomes'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 4,
      name: 'Wayanad Black Pepper',
      description: 'King of Spices harvested from certified biodynamic homestead gardens in the Western Ghats. Sun-dried berries with bold 4.25mm+ diameter, offering intense pungency and warm citrus finish.',
      category: 'Spices',
      brand: 'Wayanad Spice Collective',
      origin: 'Meppadi, Wayanad, Kerala, India',
      status: 'Verified & In Storage',
      transparencyScore: 91,
      imageUrl: 'assets/images/wayanad_black_pepper.jpg',
      batchNumber: 'WBP-TGSEB-2024-19',
      manufacturingDate: '2024-07-15',
      expiryDate: '2026-07-15',
      producerId: 7,
      producerName: 'Wayanad Spice Collective',
      ingredients: ['100% Malabar Garbled Special Extra Bold Black Peppercorns'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 5,
      name: 'Darjeeling First Flush Tea',
      description: 'Spring 2024 tender two leaves and a bud plucked at dawn from 1,800m south-facing slopes. Delivers a pale champagne liquor, lively muscatel aroma, and sweet floral notes.',
      category: 'Tea',
      brand: 'Darjeeling Heritage Estates',
      origin: 'Kurseong Valley, Darjeeling, West Bengal, India',
      status: 'Verified & Limited Edition',
      transparencyScore: 97,
      imageUrl: 'assets/images/darjeeling_tea.jpg',
      batchNumber: 'DJ-FF-2024-EX01',
      manufacturingDate: '2024-04-10',
      expiryDate: '2026-04-10',
      producerId: 8,
      producerName: 'Darjeeling Heritage Estates',
      ingredients: ['100% Organic Single Estate Darjeeling Whole Leaf Tea (FTGFOP1)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 6,
      name: 'Organic Kashmiri Saffron',
      description: 'Pure Mongra grade saffron hand-harvested from purple Crocus sativus flowers in the Karewa soils of Pampore. Unadulterated stigma tips with deep crimson pigment and high safranal concentration.',
      category: 'Spices',
      brand: 'Western Ghats Naturals',
      origin: 'Pampore, Kashmir, India',
      status: 'Verified & Vault Sealed',
      transparencyScore: 98,
      imageUrl: 'assets/images/kashmiri_saffron.jpg',
      batchNumber: 'KSH-MGR-2024-07',
      manufacturingDate: '2024-10-25',
      expiryDate: '2027-10-25',
      producerId: 5,
      producerName: 'Western Ghats Naturals',
      ingredients: ['100% Kashmiri Mongra Saffron Stigmas (ISO 3632 Category I)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 7,
      name: 'Cold-Pressed Groundnut Oil',
      description: 'Expeller pressed in traditional wooden Ghani (Mara Chekku) from indigenous Saurashtra organic peanuts at under 45°C. Unfiltered, unbleached, retaining natural nutty flavor and vitamin E.',
      category: 'Oils',
      brand: 'Green Valley Cooperative',
      origin: 'Saurashtra, Gujarat, India',
      status: 'Verified & In Production',
      transparencyScore: 89,
      imageUrl: 'assets/images/groundnut_oil.jpg',
      batchNumber: 'GVO-GN-2024-118',
      manufacturingDate: '2024-09-30',
      expiryDate: '2025-09-30',
      producerId: 2,
      producerName: 'Green Valley Cooperative',
      ingredients: ['100% Pure Cold-Pressed Virgin Peanut Oil'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 8,
      name: 'Raw Acacia Honey',
      description: 'Monofloral honey harvested from wild Acacia forests in Kashmir during the brief May blossoming window. Crystal clear, slow to crystallize, featuring a delicate mild sweetness and floral finish.',
      category: 'Honey',
      brand: 'Aster Flow Organics',
      origin: 'Baramulla, Kashmir, India',
      status: 'Verified & Distributed',
      transparencyScore: 93,
      imageUrl: 'assets/images/acacia_honey.jpg',
      batchNumber: 'AFO-ACA-2024-03',
      manufacturingDate: '2024-06-05',
      expiryDate: '2026-06-05',
      producerId: 1,
      producerName: 'Aster Flow Organics',
      ingredients: ['100% Raw Single-Source Robinia Pseudoacacia Blossom Honey'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 9,
      name: 'Single-Origin Robusta Coffee',
      description: 'High elevation washed Parchment Robusta grown at 950m in shade plantations alongside cardamom. Full-bodied, zero astringency, with dark chocolate notes and exceptional golden crema.',
      category: 'Coffee',
      brand: 'Coorg Mountain Producers',
      origin: 'Virajpet, Coorg, Karnataka, India',
      status: 'Verified & In Market',
      transparencyScore: 88,
      imageUrl: 'assets/images/robusta_coffee.jpg',
      batchNumber: 'CMP-ROB-2024-52',
      manufacturingDate: '2024-09-15',
      expiryDate: '2025-09-15',
      producerId: 6,
      producerName: 'Coorg Mountain Producers',
      ingredients: ['100% Specialty Robusta Kappi Royale (RKR Grade A)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 10,
      name: 'Organic Ceylon Cinnamon',
      description: 'True Cinnamomum verum quills hand-peeled from certified spice forests in Idukki. Thin, fragrant multi-layered rolls with ultra-low coumarin (<0.004%), sweet aroma, and no bitterness.',
      category: 'Spices',
      brand: 'Western Ghats Naturals',
      origin: 'Vandiperiyar, Idukki, Kerala, India',
      status: 'Verified & Export Ready',
      transparencyScore: 92,
      imageUrl: 'assets/images/ceylon_cinnamon.jpg',
      batchNumber: 'WGN-CIN-2024-78',
      manufacturingDate: '2024-08-14',
      expiryDate: '2026-08-14',
      producerId: 5,
      producerName: 'Western Ghats Naturals',
      ingredients: ['100% True Organic Ceylon Cinnamon Bark (Alba Quills)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 11,
      name: 'A2 Desi Ghee',
      description: 'Traditional Vedic Bilona method ghee prepared from curd cultured with indigenous Gir cow whole milk. Grass-fed, slow-simmered over firewood in clay vats, featuring rich aroma and golden granular texture.',
      category: 'Dairy & Ghee',
      brand: 'Green Valley Cooperative',
      origin: 'Gir Somnath, Gujarat, India',
      status: 'Verified & In Market',
      transparencyScore: 95,
      imageUrl: 'assets/images/desi_ghee.jpg',
      batchNumber: 'GVC-GHEE-2024-209',
      manufacturingDate: '2024-10-10',
      expiryDate: '2025-10-10',
      producerId: 2,
      producerName: 'Green Valley Cooperative',
      ingredients: ['100% Cultured Butterfat from Gir Breed Cow Milk (A2 Beta-Casein)'],
      isDemo: true,
      isVerified: true,
    ),
    Product(
      id: 12,
      name: 'Himalayan Pink Salt',
      description: 'Ancient unrefined rock salt crystals sustainably hand-mined from historic geological deposits in the Himalayan foothills. Rich in 84 trace minerals including potassium, calcium, and magnesium.',
      category: 'Salt & Minerals',
      brand: 'Himalayan Harvest Farms',
      origin: 'Foothills Geological Basin, Uttarakhand, India',
      status: 'Verified & Packaged',
      transparencyScore: 90,
      imageUrl: 'assets/images/himalayan_pink_salt.jpg',
      batchNumber: 'HHF-SALT-2024-601',
      manufacturingDate: '2024-06-25',
      expiryDate: '2028-06-25',
      producerId: 3,
      producerName: 'Himalayan Harvest Farms',
      ingredients: ['100% Raw Unrefined Food-Grade Himalayan Mineral Crystal Salt'],
      isDemo: true,
      isVerified: true,
    ),
  ];

  // 10 Users across Customer, Producer, Admin roles
  static final List<UserRecord> users = [
    UserRecord(
      id: 1,
      name: 'Ananya Sharma',
      email: 'customer@traceback.app',
      role: 'customer',
      status: 'Active',
      createdAt: '2024-01-15',
      organization: 'Consumer Member',
    ),
    UserRecord(
      id: 2,
      name: 'Rajesh Nambiar',
      email: 'producer@traceback.app',
      role: 'producer',
      status: 'Active',
      createdAt: '2024-02-10',
      organization: 'Aster Flow Organics',
    ),
    UserRecord(
      id: 3,
      name: 'Dr. Vikramaditya Rao',
      email: 'admin@traceback.app',
      role: 'admin',
      status: 'Active',
      createdAt: '2023-11-01',
      organization: 'TraceBack Lead Verifier Board',
    ),
    UserRecord(
      id: 4,
      name: 'Priya Sundaram',
      email: 'priya.s@greenvalley.org',
      role: 'producer',
      status: 'Active',
      createdAt: '2024-03-05',
      organization: 'Green Valley Cooperative',
    ),
    UserRecord(
      id: 5,
      name: 'Devendra Rawat',
      email: 'devendra@himalayanharvest.in',
      role: 'producer',
      status: 'Active',
      createdAt: '2024-03-18',
      organization: 'Himalayan Harvest Farms',
    ),
    UserRecord(
      id: 6,
      name: 'Kavita Muthappa',
      email: 'kavita@sunriseestate.co',
      role: 'producer',
      status: 'Active',
      createdAt: '2024-02-28',
      organization: 'Sunrise Estate Coffee',
    ),
    UserRecord(
      id: 7,
      name: 'Sneha Kulkarni',
      email: 'sneha.k@pune.ac.in',
      role: 'customer',
      status: 'Active',
      createdAt: '2024-04-02',
      organization: 'Food Safety Advocate',
    ),
    UserRecord(
      id: 8,
      name: 'Arjun Somvanshi',
      email: 'arjun@traceback.app',
      role: 'admin',
      status: 'Active',
      createdAt: '2023-12-12',
      organization: 'TraceBack Audit & Standards',
    ),
    UserRecord(
      id: 9,
      name: 'Meera Chidambaram',
      email: 'meera.ch@organicbuyer.com',
      role: 'customer',
      status: 'Active',
      createdAt: '2024-05-11',
      organization: 'Artisan Food Enthusiast',
    ),
    UserRecord(
      id: 10,
      name: 'Kallu Bhai Kurien',
      email: 'kurien@wayanadspices.coop',
      role: 'producer',
      status: 'Active',
      createdAt: '2024-03-22',
      organization: 'Wayanad Spice Collective',
    ),
  ];

  // 10 Batch Records
  static final List<BatchRecord> batches = [
    BatchRecord(
      id: 1,
      productId: 1,
      productName: 'Forest Bloom Wildflower Honey',
      batchNumber: 'FBH-2024-089-A',
      qrCode: 'tb://qr/batch/1/FBH-2024-089-A',
      createdAt: '2024-09-12',
      status: 'Verified & In Market',
      totalEvents: 5,
    ),
    BatchRecord(
      id: 2,
      productId: 2,
      productName: 'Coorg Arabica Coffee',
      batchNumber: 'CO-ARB-2024-041',
      qrCode: 'tb://qr/batch/2/CO-ARB-2024-041',
      createdAt: '2024-10-05',
      status: 'Active Shipment',
      totalEvents: 6,
    ),
    BatchRecord(
      id: 3,
      productId: 3,
      productName: 'Himalayan Turmeric Powder',
      batchNumber: 'HTP-8823-C',
      qrCode: 'tb://qr/batch/3/HTP-8823-C',
      createdAt: '2024-08-20',
      status: 'Verified Batch',
      totalEvents: 5,
    ),
    BatchRecord(
      id: 4,
      productId: 4,
      productName: 'Wayanad Black Pepper',
      batchNumber: 'WBP-TGSEB-2024-19',
      qrCode: 'tb://qr/batch/4/WBP-TGSEB-2024-19',
      createdAt: '2024-07-15',
      status: 'Stored in Warehouse',
      totalEvents: 4,
    ),
    BatchRecord(
      id: 5,
      productId: 5,
      productName: 'Darjeeling First Flush Tea',
      batchNumber: 'DJ-FF-2024-EX01',
      qrCode: 'tb://qr/batch/5/DJ-FF-2024-EX01',
      createdAt: '2024-04-10',
      status: 'Export Sealed',
      totalEvents: 6,
    ),
    BatchRecord(
      id: 6,
      productId: 6,
      productName: 'Organic Kashmiri Saffron',
      batchNumber: 'KSH-MGR-2024-07',
      qrCode: 'tb://qr/batch/6/KSH-MGR-2024-07',
      createdAt: '2024-10-25',
      status: 'Vault Certified',
      totalEvents: 5,
    ),
    BatchRecord(
      id: 7,
      productId: 7,
      productName: 'Cold-Pressed Groundnut Oil',
      batchNumber: 'GVO-GN-2024-118',
      qrCode: 'tb://qr/batch/7/GVO-GN-2024-118',
      createdAt: '2024-09-30',
      status: 'Bottled & Distributed',
      totalEvents: 4,
    ),
    BatchRecord(
      id: 8,
      productId: 8,
      productName: 'Raw Acacia Honey',
      batchNumber: 'AFO-ACA-2024-03',
      qrCode: 'tb://qr/batch/8/AFO-ACA-2024-03',
      createdAt: '2024-06-05',
      status: 'Verified Batch',
      totalEvents: 4,
    ),
    BatchRecord(
      id: 9,
      productId: 9,
      productName: 'Single-Origin Robusta Coffee',
      batchNumber: 'CMP-ROB-2024-52',
      qrCode: 'tb://qr/batch/9/CMP-ROB-2024-52',
      createdAt: '2024-09-15',
      status: 'Ready for Roasting',
      totalEvents: 4,
    ),
    BatchRecord(
      id: 10,
      productId: 11,
      productName: 'A2 Desi Ghee',
      batchNumber: 'GVC-GHEE-2024-209',
      qrCode: 'tb://qr/batch/10/GVC-GHEE-2024-209',
      createdAt: '2024-10-10',
      status: 'Sealed & Distributed',
      totalEvents: 5,
    ),
  ];

  // 8 Supply-Chain Activity Records
  static final List<SupplyEvent> initialJourneyEvents = [
    SupplyEvent(
      id: 1,
      batchId: 1,
      title: 'Harvesting & Sourcing',
      location: 'Nilgiris Biosphere Forest Belt, Kerala',
      date: '2024-09-10',
      organization: 'Aster Flow Apiaries Guild',
      description: 'Hand-collected from wild bee combs during the peak Strobilanthes and wildflower blooming season.',
      eventType: 'Harvest',
      isVerified: true,
    ),
    SupplyEvent(
      id: 2,
      batchId: 1,
      title: 'Cold Extraction & Filtration',
      location: 'Wayanad Processing Center, Kerala',
      date: '2024-09-14',
      organization: 'Aster Flow Quality Facility',
      description: 'Centrifugal extraction at 28°C ambient temperature. Dual mesh gravity strained without synthetic heat application.',
      eventType: 'Processing',
      isVerified: true,
    ),
    SupplyEvent(
      id: 3,
      batchId: 1,
      title: 'Purity & Pollen Analysis Lab Test',
      location: 'Regional Agmark Lab, Kozhikode',
      date: '2024-09-18',
      organization: 'National Food Quality & Purity Laboratory',
      description: 'Tested for C4 sugar adulteration, antibiotic residues, and moisture content (17.4% moisture recorded, well within limits).',
      eventType: 'Quality Analysis',
      isVerified: true,
    ),
    SupplyEvent(
      id: 4,
      batchId: 1,
      title: 'Packaging & QR Batch Coding',
      location: 'EcoPack Facility, Kochi, Kerala',
      date: '2024-09-22',
      organization: 'TraceBack Verified Packaging Node',
      description: 'Filled in sterilized amber glass jars with tamper-evident induction seal and laser-etched batch QR tag.',
      eventType: 'Packaging',
      isVerified: true,
    ),
    SupplyEvent(
      id: 5,
      batchId: 1,
      title: 'Warehouse Inward & Cold Transit',
      location: 'Central Fulfillment Hub, Bengaluru, Karnataka',
      date: '2024-09-25',
      organization: 'GreenRoute Climate Logistics',
      description: 'Arrived at temperature-monitored storage (maintained 21°C - 24°C). RFID scan matched with batch manifest.',
      eventType: 'Distribution',
      isVerified: true,
    ),
    SupplyEvent(
      id: 6,
      batchId: 2,
      title: 'Estate Hand-Harvest',
      location: 'Madikeri High Valley, Coorg, Karnataka',
      date: '2024-10-02',
      organization: 'Sunrise Estate Coffee',
      description: 'Selective picking of deep red Arabica cherries with Brix refractometer reading of 21.5% sugar.',
      eventType: 'Harvest',
      isVerified: true,
    ),
    SupplyEvent(
      id: 7,
      batchId: 2,
      title: 'Fermentation & Raised Bed Drying',
      location: 'Sunrise Estate Wet Mill, Coorg',
      date: '2024-10-05',
      organization: 'Specialty Coffee Wet Mill Guild',
      description: '24-hour anaerobic fermentation followed by natural mountain patio drying to 11% parchment moisture.',
      eventType: 'Processing',
      isVerified: true,
    ),
    SupplyEvent(
      id: 8,
      batchId: 2,
      title: 'Cupping & Sensory Audit',
      location: 'Q-Grader Sensory Lab, Bengaluru',
      date: '2024-10-18',
      organization: 'Coffee Board of India Accredited Lab',
      description: 'SCA cupping score evaluated at 86.75 points. Tasting notes: Orange blossom, sugarcane sweetness, dark cocoa finish.',
      eventType: 'Quality Analysis',
      isVerified: true,
    ),
  ];

  // 6 Document / Certificate Examples
  static final List<DocumentItem> initialDocuments = [
    DocumentItem(
      id: 1,
      productId: 1,
      name: 'NPOP_Organic_Certificate_2024.pdf',
      status: 'verified',
      notes: 'Certified by Aditi Organic Certifications under NPOP guidelines. Annual on-site audit cleared without infractions.',
      documentType: 'Organic Certification',
      fileHash: 'SHA256:d82e448b4e76a6cf49dfc12b70f074d284f1f23c72b2203be4fa6468725d2be5',
      uploaderName: 'Aster Flow Organics',
      date: '2024-09-12',
      isDemo: true,
    ),
    DocumentItem(
      id: 2,
      productId: 1,
      name: 'Lab_Report_Antibiotic_Purity_Test.pdf',
      status: 'verified',
      notes: 'LC-MS/MS test confirms zero antibiotic contamination, zero sucrose syrup adulteration. FSSAI compliant.',
      documentType: 'Purity & Residue Analysis',
      fileHash: 'SHA256:1a58e69d7a22cd68f2f231e5f88e63a15dcbd04c27a29e4776b92f44a86b5c3e',
      uploaderName: 'Aster Flow Organics',
      date: '2024-09-19',
      isDemo: true,
    ),
    DocumentItem(
      id: 3,
      productId: 2,
      name: 'Rainforest_Alliance_Coorg_Audit.pdf',
      status: 'verified',
      notes: 'Biodiversity conservation compliance confirmed: Shade canopy density 42%, zero synthetic agrochemicals used.',
      documentType: 'Sustainability Audit',
      fileHash: 'SHA256:39f1c7117e33503f8a4427c3e5a3cbb5b1b4b7c02b9e4a819b9d3e8e7a6f2c1b',
      uploaderName: 'Sunrise Estate Coffee',
      date: '2024-10-06',
      isDemo: true,
    ),
    DocumentItem(
      id: 4,
      productId: 3,
      name: 'Curcumin_Potency_Assay_Ranikhet.pdf',
      status: 'verified',
      notes: 'Spectrophotometric evaluation confirms 6.82% curcumin content, surpassing minimum Grade I standards.',
      documentType: 'Chemical Assay',
      fileHash: 'SHA256:7f4a21e69b82cb412d091e3e7f6c5b4a3d2e1f0a9b8c7d6e5f4a3b2c1d0e9f8a',
      uploaderName: 'Himalayan Harvest Farms',
      date: '2024-08-22',
      isDemo: true,
    ),
    DocumentItem(
      id: 5,
      productId: 6,
      name: 'GI_Tag_Verification_Kashmir_Saffron.pdf',
      status: 'pending',
      notes: 'Application submitted for Geographical Indication validation seal under Certificate Directorate, Pampore.',
      documentType: 'GI Registration',
      fileHash: 'SHA256:88e1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1',
      uploaderName: 'Western Ghats Naturals',
      date: '2024-10-27',
      isDemo: true,
    ),
    DocumentItem(
      id: 6,
      productId: 7,
      name: 'Cold_Press_Aflatoxin_Safety_Scan.pdf',
      status: 'verified',
      notes: 'ELISA screening indicates total aflatoxin < 1.2 ppb (limit is 15 ppb). Clean and safe for distribution.',
      documentType: 'Toxicology & Safety',
      fileHash: 'SHA256:99f0e1d2c3b4a5f6e7d8c9b0a1f2e3d4c5b6a7f8e9d0c1b2a3f4e5d6c7b8a9f0',
      uploaderName: 'Green Valley Cooperative',
      date: '2024-10-02',
      isDemo: true,
    ),
  ];

  // 6 Recent Activity Entries
  static final List<ActivityRecord> activities = [
    ActivityRecord(
      id: 'act-1',
      title: 'Batch Certified & Released',
      subtitle: 'Forest Bloom Wildflower Honey (#FBH-2024-089-A) cleared Agmark lab verification.',
      timestamp: '2 hours ago',
      type: 'verify',
    ),
    ActivityRecord(
      id: 'act-2',
      title: 'New Harvest Document Uploaded',
      subtitle: 'Sunrise Estate Coffee uploaded RainForest Alliance audit report for Batch #CO-ARB-2024-041.',
      timestamp: '5 hours ago',
      type: 'create',
    ),
    ActivityRecord(
      id: 'act-3',
      title: 'Consumer Verification Scan',
      subtitle: 'Batch #HTP-8823-C scanned in Bengaluru, Karnataka. Transparency score 96/100 verified.',
      timestamp: '1 day ago',
      type: 'scan',
    ),
    ActivityRecord(
      id: 'act-4',
      title: 'Supply-Chain Milestone Added',
      subtitle: 'Green Valley Cooperative added Mara Chekku cold-pressing timestamp to Batch #GVO-GN-2024-118.',
      timestamp: '1 day ago',
      type: 'update',
    ),
    ActivityRecord(
      id: 'act-5',
      title: 'GI Tag Verification Submitted',
      subtitle: 'Pampore Mongra Saffron batch submitted for verifier approval.',
      timestamp: '2 days ago',
      type: 'verify',
    ),
    ActivityRecord(
      id: 'act-6',
      title: 'Producer Registration Approved',
      subtitle: 'Darjeeling Heritage Estates joined TraceBack Verified Producer Collective.',
      timestamp: '3 days ago',
      type: 'create',
    ),
  ];

  // In-Memory Mutables for Interactive Frontend Demo Experience
  static final List<Product> _mutableProducts = List<Product>.from(initialProducts);
  static final List<DocumentItem> _mutableDocuments = List<DocumentItem>.from(initialDocuments);
  static final List<BatchRecord> _mutableBatches = List<BatchRecord>.from(batches);
  static final List<SupplyEvent> _mutableEvents = List<SupplyEvent>.from(initialJourneyEvents);
  static final Set<int> _savedProductIds = {1, 3, 5};
  static final List<int> _recentProductIds = [1, 2, 4, 3];

  static List<Product> getProducts() => List.unmodifiable(_mutableProducts);

  static Product? getProductById(int id) {
    try {
      return _mutableProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return _mutableProducts.isNotEmpty ? _mutableProducts.first : null;
    }
  }

  static List<DocumentItem> getDocuments() => List.unmodifiable(_mutableDocuments);

  static List<DocumentItem> getDocumentsForProduct(int productId) =>
      _mutableDocuments.where((doc) => doc.productId == productId || productId == 0).toList();

  static List<BatchRecord> getBatches() => List.unmodifiable(_mutableBatches);

  static List<SupplyEvent> getJourneyEvents(int batchId) {
    final matches = _mutableEvents.where((e) => e.batchId == batchId).toList();
    if (matches.isNotEmpty) return matches;
    return _mutableEvents.take(5).toList();
  }

  static bool isProductSaved(int id) => _savedProductIds.contains(id);

  static void toggleSavedProduct(int id) {
    if (_savedProductIds.contains(id)) {
      _savedProductIds.remove(id);
    } else {
      _savedProductIds.add(id);
    }
  }

  static List<Product> getSavedProducts() =>
      _mutableProducts.where((p) => _savedProductIds.contains(p.id)).toList();

  static List<Product> getRecentProducts() {
    return _recentProductIds
        .map((id) => getProductById(id))
        .whereType<Product>()
        .toList();
  }

  static void recordProductView(int id) {
    _recentProductIds.remove(id);
    _recentProductIds.insert(0, id);
    if (_recentProductIds.length > 8) {
      _recentProductIds.removeLast();
    }
  }

  static void updateDocumentStatus(int documentId, String newStatus, String remarks) {
    final index = _mutableDocuments.indexWhere((doc) => doc.id == documentId);
    if (index != -1) {
      final doc = _mutableDocuments[index];
      _mutableDocuments[index] = doc.copyWith(
        status: newStatus.toLowerCase(),
        notes: remarks.isNotEmpty ? remarks : doc.notes,
      );
    }
  }

  static void addProduct(Product product) {
    _mutableProducts.insert(0, product);
  }

  static void addBatch(BatchRecord batch) {
    _mutableBatches.insert(0, batch);
  }

  static void addJourneyEvent(SupplyEvent event) {
    _mutableEvents.add(event);
  }

  static void addDocument(DocumentItem document) {
    _mutableDocuments.insert(0, document);
  }
}
