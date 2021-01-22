class Expense {
  final int id;
  final String expenseContent;
  final double amount;
  final int type; // 1: thu vào, 0: chi ra
  final int categoryId;
  final String date;

  Expense({this.id, this.expenseContent, this.amount, this.type, this.categoryId, this.date});

  factory Expense.fromMap(Map<String, dynamic> map){
    return Expense(
      id: map['id'],
      expenseContent: map['expense_content'],
      amount: map['amount'],
      type: map['type'],
      categoryId: map['category_id'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_content': expenseContent,
      'amount': amount,
      'type': type,
      'category_id':categoryId,
      'date': date,
    };
  }



}
