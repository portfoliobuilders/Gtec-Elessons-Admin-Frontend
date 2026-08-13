/// One regional price — used both inline in the Grade/Subject/Chapter
/// CREATE requests (`prices: [...]`, confirmed live to auto-create the
/// Product + all its ProductPrice rows in one call) and standalone via
/// `POST /admin/pricing/products/:productId/prices` (adding a region to an
/// already-existing product). `amount`/`compareAt` are canonical currency
/// amounts, never minor units.
class CreatePriceRequest {
  const CreatePriceRequest({required this.region, required this.currency, required this.amount, this.compareAt});

  final String region;
  final String currency;
  final num amount;
  final num? compareAt;

  Map<String, dynamic> toJson() => {
        'region': region,
        'currency': currency,
        'amount': amount,
        if (compareAt != null) 'compareAt': compareAt,
      };
}

/// `PATCH /admin/pricing/products/:productId/prices/:priceId` — corrects
/// the amount/compareAt on a regional price the product already has.
/// Region/currency are not editable this way — changing which region a row
/// represents is a delete-and-recreate (region+currency is the row's
/// identity, see [CreatePriceRequest]).
class UpdateProductPriceRequest {
  const UpdateProductPriceRequest({this.amount, this.compareAt});

  final num? amount;
  final num? compareAt;

  Map<String, dynamic> toJson() => {
        if (amount != null) 'amount': amount,
        if (compareAt != null) 'compareAt': compareAt,
      };
}
