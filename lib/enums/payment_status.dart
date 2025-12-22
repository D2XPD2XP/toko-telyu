enum PaymentStatus { pending, completed, failed }

PaymentStatus parsePaymentStatus(String? value) {
  switch (value) {
    case "completed":
      return PaymentStatus.completed;
    case "failed":
      return PaymentStatus.failed;
    case "pending":
    default:
      return PaymentStatus.pending;
  }
}
