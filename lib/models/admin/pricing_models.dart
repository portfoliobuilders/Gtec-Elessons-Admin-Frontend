// Backend-aligned Pricing models — mirrors AdminPricingService (GET
// /admin/pricing, POST/PATCH/DELETE /admin/pricing/products/:id/prices).
//
// Phase 5: the backend now supports multiple regional ProductPrice rows per
// Product (one Grade/Subject/Chapter Product, many prices — one per
// region/currency). Money fields are canonical currency amounts (e.g.
// `12000` for ₹12,000), confirmed live — the backend also still returns
// legacy `amountCents`/`compareAtCents` minor-unit fields for backward
// compatibility, deliberately not parsed here; Flutter never multiplies or
// divides by 100.

/// Backend enums (exact wire values, do not rename):
/// ProductType: FULL_CLASS | MENTORSHIP | SUBJECT | MODULE (MODULE == chapter)
/// ProductFormat: RECORDED | LIVE_AND_RECORDED
class AdminProductModel {
  const AdminProductModel({
    required this.id,
    required this.type,
    required this.format,
    required this.title,
    this.isActive = true,
    this.gradeId,
    this.subjectId,
    this.chapterId,
    this.accessDays = 365,
    this.prices = const [],
  });

  final String id;
  final String type;
  final String format;
  final String title;
  final bool isActive;
  final String? gradeId;
  final String? subjectId;
  final String? chapterId;
  final int accessDays;
  final List<AdminProductPriceModel> prices;

  factory AdminProductModel.fromJson(Map<String, dynamic> json) => AdminProductModel(
        id: json['id'] as String,
        type: json['type'] as String,
        format: json['format'] as String? ?? 'RECORDED',
        title: json['title'] as String,
        isActive: json['isActive'] as bool? ?? true,
        gradeId: json['gradeId'] as String?,
        subjectId: json['subjectId'] as String?,
        chapterId: json['chapterId'] as String?,
        accessDays: json['accessDays'] as int? ?? 365,
        prices: (json['prices'] as List<dynamic>?)
                ?.map((e) => AdminProductPriceModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}

/// A single regional price row for a Product. Used both for the flattened
/// `prices` array nested under Grade/Subject/Chapter (from
/// `GET /admin/curriculum` and the create/update responses — no `priceId`
/// there, confirmed live) and for the full price row `AdminPricingService`
/// returns (`GET /admin/pricing`, `POST/PATCH .../prices` — which does
/// include `priceId`, needed to PATCH/DELETE a specific row later).
class AdminProductPriceModel {
  const AdminProductPriceModel({
    this.priceId,
    required this.productId,
    required this.region,
    required this.currency,
    required this.amount,
    this.compareAt,
  });

  final String? priceId;
  final String productId;
  final String region;
  final String currency;
  final num amount;
  final num? compareAt;

  factory AdminProductPriceModel.fromJson(Map<String, dynamic> json) => AdminProductPriceModel(
        priceId: json['id'] as String?,
        productId: json['productId'] as String,
        region: json['region'] as String,
        currency: json['currency'] as String,
        amount: json['amount'] as num,
        compareAt: json['compareAt'] as num?,
      );
}
