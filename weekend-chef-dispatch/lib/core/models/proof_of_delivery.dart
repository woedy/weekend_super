class ProofOfDelivery {
  const ProofOfDelivery({
    required this.capturedAt,
    this.signatureImage,
    this.photoPath,
    this.notes,
  });

  final DateTime capturedAt;
  final String? signatureImage;
  final String? photoPath;
  final String? notes;
}
