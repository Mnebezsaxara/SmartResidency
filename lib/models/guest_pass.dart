class GuestPass {
  final String id;
  final String guestName;
  final String phone;
  final bool byCar;
  final String? carNumber;
  final DateTime validFrom;
  final DateTime validTo;
  bool isUsed;

  GuestPass({
    required this.id,
    required this.guestName,
    required this.phone,
    required this.byCar,
    this.carNumber,
    required this.validFrom,
    required this.validTo,
    this.isUsed = false,
  });
}