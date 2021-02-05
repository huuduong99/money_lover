import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/model/expense_model.dart';
import 'package:money_lover/model/payment_method_model.dart';
import 'package:money_lover/page/insert_expense_page.dart';
import 'package:money_lover/page/update_expense_page.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final List<String> _dateRangeList = [
    'Tất cả',
    'Tháng này',
    'Tháng trước',
    'Tuần này',
    'Tùy chọn'
  ];
  String _currentItemSelected;
  final SlidableController _slidableController = SlidableController();
  static DBHelper dbHelper = DBHelper();
  List<Expense> _expenses = <Expense>[];
  List<Category> _categories = <Category>[];
  List<PaymentMethod> _paymentMethods = <PaymentMethod>[];
  double _income = 0;
  double _spending = 0;
  DateTime _startDate, _endDate;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _setLoadDefaultExpense();
  }

  _setLoadDefaultExpense() {
    _currentItemSelected = 'Tuần này';
    final currentDate = DateTime.now();
    var monday = currentDate
        .subtract(Duration(days: currentDate.weekday - 1)); //load tuần này
    _startDate = DateTime(monday.year, monday.month, monday.day);
    _endDate = DateTime.now();
    _loadExpenses();
  }

  void _checkRangeDateTime(int date) async {
    switch (date) {
      case 1: // tất cả
        _startDate = null;
        _endDate = null;
        break;

      case 2: // tháng này
        final currentDate = DateTime.now();
        _startDate = DateTime(currentDate.year, currentDate.month, 1);
        _endDate = DateTime(currentDate.year, currentDate.month + 1, 0, 23, 59);
        break;

      case 3: // tháng trước
        final currentDate = DateTime.now();
        _startDate = DateTime(currentDate.year, currentDate.month - 1, 1);
        _endDate = DateTime(currentDate.year, currentDate.month, 0, 23, 59);
        break;

      case 4: //tuần này
        final currentDate = DateTime.now();
        var monday =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
        _startDate = DateTime(monday.year, monday.month, monday.day);
        _endDate = DateTime.now();
        break;

      case 5: //tuần này
        final date = await showDateRangePicker(
          context: context,
          firstDate: DateTime(DateTime.now().year - 5),
          lastDate: DateTime(DateTime.now().year + 5),
          initialDateRange: DateTimeRange(
            end: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 6),
            start: DateTime.now(),
          ),
        );

        if (date != null) {
          _startDate = date.start;
          _endDate =
              DateTime(date.end.year, date.end.month, date.end.day, 23, 59);
        } else {
          _setLoadDefaultExpense();
        }
        break;

      default:
        break;
    }
    _loadExpenses();
  }

  void _loadExpenses() async {
    _getTotalSumEachTypeExpenses();
    String _start =
    _startDate != null ? _dateFormat.format(_startDate).toString() : null;
    String _end =
    _endDate != null ? _dateFormat.format(_endDate).toString() : null;
    final List<Expense> listExpense =
    await dbHelper.getExpenseInDatetimeRange(_start, _end);
    final List<Category> listCategory = await dbHelper.getCategories();
    final List<PaymentMethod> listPaymentMethod =
    await dbHelper.getPaymentMethod();

    if (this.mounted) { // check whether the state object is in tree
      setState(() {
        _expenses = listExpense;
        _categories = listCategory;
        _paymentMethods = listPaymentMethod;
      });
    }

  }

  String _getNameCategory(int id) {
    for (var record in _categories) {
      if (record.id == id) {
        return record.name;
      }
    }
    return '';
  }

  String _getNamePaymentMethod(int id) {
    for (var record in _paymentMethods) {
      if (record.id == id) {
        return record.methodName;
      }
    }
    return '';
  }

  _getTotalSumEachTypeExpenses() async {
    String _start =
    _startDate != null ? _dateFormat.format(_startDate).toString() : null;
    String _end =
    _endDate != null ? _dateFormat.format(_endDate).toString() : null;

    final sumIncome = (await dbHelper.calculateTotalEachTypeExpenses(
        1, _start, _end))[0]['totalSum']; //1 là thu vào
    final sumSpending = (await dbHelper.calculateTotalEachTypeExpenses(
        0, _start, _end))[0]['totalSum']; //0 là chi ra

    if (this.mounted) { // check whether the state object is in tree
      setState(() {
        _income = sumIncome ?? 0;
        _spending = sumSpending ?? 0;
      });
    }

  }

  Widget _buildRowAmount(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(NumberFormat.simpleCurrency(locale: 'vi').format(amount),
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  _handleDelete(int id) {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Xác nhận"),
        content: Text('Bạn có chắc chắn muốn xóa ?'),
        actions: [
          FlatButton(
              onPressed: () async {
                await dbHelper.deleteExpense(id);
                _checkRangeDateTime(
                    _dateRangeList.indexOf(_currentItemSelected) + 1);
                Navigator.pop(context);
              },
              child: Text('OK')),
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'))
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Thu chi'),
      backgroundColor: Colors.blue,
      actions: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsertExpensePage()))
                  .then((value) {
                _checkRangeDateTime(
                    _dateRangeList.indexOf(_currentItemSelected) + 1);
              });
            })
      ],
    );
  }

  Widget _buildCardTotalExpense() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: Offset(1, 2),
                blurRadius: 1,
                spreadRadius: 1)
          ],
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Column(
        children: [
          _buildRowAmount('Thu:', _income, Colors.green),
          const Divider(),
          _buildRowAmount('Chi:', _spending, Colors.red),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Thời gian:',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(width: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        _startDate != null
                            ? _dateFormat.format(_startDate).toString()
                            : 'Từ đầu',
                        style: TextStyle(
                            color: Color(0xFFb8a9b6),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    Text(
                        _endDate != null
                            ? _dateFormat.format(_endDate).toString()
                            : 'Hết',
                        style: TextStyle(
                            color: Color(0xFFb8a9b6),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterExpense() {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Lịch sử',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 35,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFF28A745),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return _dateRangeList.map((title) {
                      return PopupMenuItem(
                        value: title,
                        child: Text(title),
                      );
                    }).toList();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _currentItemSelected,
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  onSelected: (v) {
                    setState(() {
                      _currentItemSelected = v;
                      _checkRangeDateTime(
                          _dateRangeList.indexOf(_currentItemSelected) + 1);
                    });
                  }))
        ],
      ),
    );
  }

  Widget _buildItem(Expense expense) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: Offset(1, 2),
                blurRadius: 1,
                spreadRadius: 1)
          ],
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.categoryId != null
                      ? _getNameCategory(expense.categoryId)
                      : 'Unknown',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(expense.date.toString(),
                    style: TextStyle(
                        color: Color(0xFFb8a9b6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    NumberFormat.simpleCurrency(locale: 'vi')
                        .format(expense.amount),
                    style: TextStyle(
                        color: expense.type == 1 ? Colors.green : Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(
                    expense.paymentMethodId != null
                        ? _getNamePaymentMethod(expense.paymentMethodId)
                        : 'Unknown',
                    style: TextStyle(
                        color: Color(0xFFb8a9b6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRowItem(Expense expense) {
    return Slidable(
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: _buildItem(expense),
      secondaryActions: [
        IconSlideAction(
            color: Color(0xFFFAFAFA),
            icon: Icons.edit,
            foregroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateExpensePage(
                      expenseDetail: expense,
                    ),
                  )).then((value) {
                _checkRangeDateTime(
                    _dateRangeList.indexOf(_currentItemSelected) + 1);
              });
            }),
        IconSlideAction(
          color: Color(0xFFFAFAFA),
          icon: Icons.delete,
          foregroundColor: Colors.red,
          onTap: () => _handleDelete(expense.id),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Scrollbar(
      thickness: 5.0,
      child: ListView.builder(
        itemCount: _expenses.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) =>
            _buildRowItem(_expenses[index]),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterExpense(),
          _buildCardTotalExpense(),
          Expanded(child: _buildListView())
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}
