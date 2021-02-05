class Expense {
  final int id;
  final double amount;
  final int type; // 1: thu vào, 0: chi ra
  final int categoryId;
  final int paymentMethodId;
  final String date;

  Expense(
      {this.id, this.amount, this.type, this.categoryId, this.paymentMethodId, this.date});

  factory Expense.fromMap(Map<String, dynamic> map){
    return Expense(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      paymentMethodId: map['payment_method_id'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'payment_method_id': paymentMethodId,
      'date': date,
    };
  }


}
