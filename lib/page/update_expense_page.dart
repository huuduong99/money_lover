import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/model/expense_model.dart';
import 'package:money_lover/model/payment_method_model.dart';
import 'package:money_lover/page/select_category_expense_page.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class UpdateExpensePage extends StatefulWidget {
  final Expense expenseDetail;

  UpdateExpensePage({@required this.expenseDetail});

  @override
  _UpdateExpensePageState createState() => _UpdateExpensePageState();
}

class _UpdateExpensePageState extends State<UpdateExpensePage> {
  static DBHelper dbHelper = DBHelper();
  final List<String> _styleExpense = ['Thu vào', 'Chi ra'];
  List<String> _paymentMethods = <String>[];
  List<PaymentMethod> _listPaymentMethod = <PaymentMethod>[];
  String _currentItemStyleSelected;
  String _currentItemPaymentMethodSelected;
  Category _category;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  String _date;
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = _dateFormat.format(DateTime.now());
    _initialValueField();
    _getPaymentMethod();
  }

  void _initialValueField() {
    _currentItemStyleSelected =
    widget.expenseDetail.type == 1 ? 'Thu vào' : 'Chi ra';
    _amountController.text = widget.expenseDetail.amount.toInt().toString();
    _date = widget.expenseDetail.date;
  }

  _getPaymentMethod() async {
    if (_paymentMethods != null) {
      _paymentMethods.clear();
    }
    _listPaymentMethod = await dbHelper.getPaymentMethod();
    for (var paymentMethod in _listPaymentMethod) {
      _paymentMethods.add(paymentMethod.methodName);
    }
  }

  _getPaymentMethodById(int id) async {
    for (var paymentMethod in _listPaymentMethod) {
      if (paymentMethod.id == id) {
        return paymentMethod;
      }
    }
    return null;
  }

  Widget _buildDropdownSelect(
      String title, List<String> options, String currentItem, onSelected) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          Theme(
              data:
              Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return options.map((item) {
                      return PopupMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        currentItem != null ? currentItem : "",
                        style: TextStyle(fontSize: 15),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  onSelected: onSelected))
        ],
      ),
    );
  }

  _onSelectedType(value) {
    setState(() {
      _currentItemStyleSelected = value;
    });
  }

  _onSelectedPaymentMethod(value) {
    setState(() {
      _currentItemPaymentMethodSelected = value;
    });
  }

  Widget _buildCalendar() {
    return ListTile(
        leading: Icon(
          Icons.calendar_today,
          color: Colors.blue,
        ),
        title: Text(_date),
        onTap: () async {
          final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1999, 1),
              lastDate: DateTime(2050, 12));

          final time = await showTimePicker(
              context: context, initialTime: TimeOfDay.now());
          setState(() {
            if (date != null && time != null) {
              final dateTime = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
              _date = _dateFormat.format(dateTime);
            }
          });
        });
  }

  Widget _buildInputText(TextEditingController controller, int maxLines,
      TextInputType inputType, bool formatter, String hint) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: Colors.black,
      keyboardType: inputType,
      inputFormatters: !formatter
          ? null
          : <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(17),
        ThousandsFormatter()
      ],
      decoration: new InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hint,
          hintStyle:
          TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildButtonExit() {
    return RawMaterialButton(
      onPressed: () => Navigator.pop(context),
      elevation: 2.0,
      fillColor: Colors.red,
      child: Icon(
        Icons.close,
        size: 15.0,
        color: Colors.white,
      ),
      padding: EdgeInsets.all(1.0),
      shape: CircleBorder(),
    );
  }

  Widget _buildButtonSave() {
    return RawMaterialButton(
      onPressed: () => _handleSaveUpdateExpense(),
      elevation: 2.0,
      fillColor: Colors.blue,
      child: Icon(
        Icons.done,
        size: 35.0,
        color: Colors.white,
      ),
      padding: EdgeInsets.all(15.0),
      shape: CircleBorder(),
    );
  }

  _handleSaveUpdateExpense() async {
    try {
      if (_amountController.text != null) {
        final paymentMethod = _currentItemPaymentMethodSelected != null
            ? _listPaymentMethod[_paymentMethods.indexOf(_currentItemPaymentMethodSelected)]
            : _getPaymentMethodById(widget.expenseDetail.paymentMethodId);
        final amount = double.parse(
            _amountController.text.replaceAll(new RegExp(r','), ''));
        final type = _currentItemStyleSelected == 'Thu vào' ? 1 : 0;

        await dbHelper.updateExpense(Expense(
            id: widget.expenseDetail.id,
            amount: amount,
            type: type,
            categoryId: _category != null
                ? _category.id
                : widget.expenseDetail.categoryId,
            paymentMethodId: paymentMethod != null
                ? paymentMethod.id
                : widget.expenseDetail.paymentMethodId,
            date: _date));

        if (paymentMethod != null) {
          await dbHelper.updatePaymentMethod(PaymentMethod(
            id: paymentMethod.id,
            methodName: paymentMethod.methodName,
            balance: type == 1
                ? (paymentMethod.balance + amount)
                : (paymentMethod.balance - amount),
          ));
        }

        Navigator.pop(context);
      } else {
        _handleShowError();
      }
    } catch (e) {
      _handleShowError();
    }
  }

  _handleShowError() {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Lỗi"),
        content: Text('Vui lòng nhập đầy đủ thông tin'),
        actions: [
          FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK')),
        ],
      ),
    );
  }

  Widget _buildFieldCategory() {
    return Padding(
      padding: EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Danh mục',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Row(
            children: [
              Text(_category != null ? _category.name : ''),
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_right_sharp),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SelectCategoryExpensePage())).then((result) {
                      if (result != null) {
                        setState(() {
                          _category = result;
                        });
                      }
                    });
                  }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFF2F3F5),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 20, top: 50, right: 30, bottom: 80),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    offset: Offset(1, 2),
                    blurRadius: 1,
                    spreadRadius: 1)
              ],
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                  child: Column(
                    children: [
                      Text('Sửa thu chi',
                          style: TextStyle(fontSize: 25, color: Colors.blue)),
                      const Divider(),
                      _buildFieldCategory(),
                      const Divider(),
                      _buildDropdownSelect('Loại', _styleExpense,
                          _currentItemStyleSelected, _onSelectedType),
                      const Divider(),
                      _buildDropdownSelect(
                          'Nguồn tiền',
                          _paymentMethods,
                          _currentItemPaymentMethodSelected,
                          _onSelectedPaymentMethod),
                      const Divider(),
                      _buildInputText(_amountController, 1,
                          TextInputType.number, true, 'Số tiền'),
                      const Divider(),
                      _buildCalendar(),
                      const Divider(),
                    ],
                  ),
                ),
              ),
              Positioned(top: -20, right: -40, child: _buildButtonExit()),
              Positioned(
                  bottom: -30, left: 10, right: 10, child: _buildButtonSave()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: _buildBody(),
      ),
    );
  }
}
