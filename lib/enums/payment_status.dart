enum PaymentStatus { pending, completed, failed }

PaymentStatus parsePaymentStatus(String? value) {
  switch (value) {
    case "completed":
      return PaymentStatus.completed;
    case "failure":
      return PaymentStatus.failed;
    case "pending":
    default:
      return PaymentStatus.pending;
  }
}
