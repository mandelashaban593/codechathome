class PaymentModel {
  final String doctor;
  final double amount;
  final String status;

  PaymentModel({
    required this.doctor,
    required this.amount,
    required this.status,
  });

  factory PaymentModel.fromJson(Map json) {
    return PaymentModel(
      doctor: json['doctor'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
    );
  }
}