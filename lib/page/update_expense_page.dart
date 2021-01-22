import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/model/expense_model.dart';
import 'package:money_lover/page/select_category_expense_page.dart';

class UpdateExpensePage extends StatefulWidget {
  final Expense expenseDetail;

  UpdateExpensePage({@required this.expenseDetail});

  @override
  _UpdateExpensePageState createState() => _UpdateExpensePageState();
}

class _UpdateExpensePageState extends State<UpdateExpensePage> {
  static DBHelper dbHelper = DBHelper();
  final List<String> _style = ['Thu vào', 'Chi ra'];
  String _currentItemStyleSelected;
  Category _category;

  final _dateFormat = new DateFormat('dd-MM-yyyy');
  String _date;
  TextEditingController _contentController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = _dateFormat.format(DateTime.now());
    _initialValueField();
  }

  void _initialValueField() {
    _contentController.text = widget.expenseDetail.expenseContent.toString();
    _amountController.text = widget.expenseDetail.amount.toInt().toString();
    _currentItemStyleSelected = widget.expenseDetail.type == 1 ? 'Thu vào' : 'Chi ra';
    _date = widget.expenseDetail.date;
  }

  Widget _buildDropdownSelect() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Loại",
            style: TextStyle(fontSize: 15),
          ),
          Theme(
              data:
              Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: PopupMenuButton<String>(
                itemBuilder: (context) {
                  return _style.map((item) {
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
                      _currentItemStyleSelected != null
                          ? _currentItemStyleSelected
                          : "",
                      style: TextStyle(fontSize: 15),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ],
                ),
                onSelected: (value) {
                  setState(() {
                    _currentItemStyleSelected = value;
                  });
                },
              ))
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return ListTile(
        leading: Icon(
          Icons.calendar_today,
          color: Colors.red,
        ),
        title: Text(_date),
        onTap: () async {
          final result = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1999, 1),
              lastDate: DateTime(2050, 12));
          setState(() {
            if (result != null) {
              _date = _dateFormat.format(result);
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
          : <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      decoration: new InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
          EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hint),
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
      fillColor: Color(0xFFC89AF2),
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
      if (_contentController.text != "" && _amountController.text != "") {
        final Expense expense = Expense(
            id: widget.expenseDetail.id,
            expenseContent: _contentController.text,
            amount: double.parse(_amountController.text),
            type: _currentItemStyleSelected == 'Thu vào' ? 1 : 0,
            categoryId: _category != null ? _category.id : widget.expenseDetail.categoryId,
            date: _date
        );
        await dbHelper.insertExpense(expense);
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
          Text('Danh mục'),
          Row(
            children: [
              Text(_category != null ? _category.name : ''),
              IconButton(
                  icon: Icon(Icons.add),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFC98CE4),
            Color(0xFF936FDD),
          ],
        ),
      ),
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
                    color: Colors.white.withOpacity(0.2),
                    offset: Offset(15, -15),
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                child: Column(
                  children: [
                    Text('Sửa thu chi',
                        style: TextStyle(fontSize: 25, color: Colors.blue)),
                    const Divider(),
                    _buildDropdownSelect(),
                    const Divider(),
                    _buildFieldCategory(),
                    const Divider(),
                    _buildInputText(_amountController, 1, TextInputType.number,
                        true, 'Số tiền'),
                    const Divider(),
                    _buildInputText(_contentController, 3, TextInputType.text,
                        false, 'Nội dung'),
                    const Divider(),
                    _buildCalendar(),
                    const Divider(),
                  ],
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
