class PaymentPlan {
  final String? planId;
  final String planType; // MONTHLY, YEARLY
  final String name;
  final int price;
  final String currency;
  final int durationDays;

  PaymentPlan({
    this.planId,
    required this.planType,
    required this.name,
    required this.price,
    required this.currency,
    required this.durationDays,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      planId: json['planId']?.toString(),
      planType: json['planType']?.toString() ?? 'MONTHLY',
      name: json['name']?.toString() ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '') ?? 0,
      currency: json['currency']?.toString() ?? 'VND',
      durationDays: json['durationDays'] is int ? json['durationDays'] : int.tryParse(json['durationDays']?.toString() ?? '') ?? 30,
    );
  }
}

class PaymentOrderResponse {
  final String transactionId;
  final String providerTransactionId;
  final String provider;
  final String planType;
  final int amount;
  final String status; // PENDING, SUCCESS, FAILED
  final String qrCodeData;
  final String deepLink;
  final String expiresAt;

  PaymentOrderResponse({
    required this.transactionId,
    required this.providerTransactionId,
    required this.provider,
    required this.planType,
    required this.amount,
    required this.status,
    required this.qrCodeData,
    required this.deepLink,
    required this.expiresAt,
  });

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderResponse(
      transactionId: json['transactionId']?.toString() ?? '',
      providerTransactionId: json['providerTransactionId']?.toString() ?? '',
      provider: json['provider']?.toString() ?? 'MOMO',
      planType: json['planType']?.toString() ?? 'MONTHLY',
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      qrCodeData: json['qrCodeData']?.toString() ?? '',
      deepLink: json['deepLink']?.toString() ?? '',
      expiresAt: json['expiresAt']?.toString() ?? '',
    );
  }
}

class DictionaryEntry {
  final int id;
  final String entryId;
  final String word;
  final String category;
  final String difficulty;
  final String description;
  final String? videoUrl;
  final String? thumbnailUrl;

  DictionaryEntry({
    required this.id,
    required this.entryId,
    required this.word,
    required this.category,
    required this.difficulty,
    required this.description,
    this.videoUrl,
    this.thumbnailUrl,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      entryId: json['entryId']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}
