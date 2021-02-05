class PaymentMethod {
  final int id;
  final String methodName;
  final double balance;

  PaymentMethod({this.id, this.methodName,this.balance});

  factory PaymentMethod.fromMap(Map<String, dynamic> map){
    return PaymentMethod(
        id: map['id'],
        methodName: map['method_name'],
        balance: map['balance']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method_name': methodName,
      'balance': balance
    };
  }



}