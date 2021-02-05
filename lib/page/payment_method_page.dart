import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/payment_method_model.dart';
import 'package:pattern_formatter/pattern_formatter.dart';

class PaymentMethodPage extends StatefulWidget {
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  static DBHelper dbHelper = DBHelper();
  List<PaymentMethod> _paymentMethods = <PaymentMethod>[];
  TextEditingController _paymentMethodController = TextEditingController();
  TextEditingController _balanceController = TextEditingController();
  final SlidableController _slidableController = SlidableController();

  @override
  void initState() {
    super.initState();
    _getPaymentMethod();
  }

  _getPaymentMethod() async {
    final List<PaymentMethod> listPaymentMethod =
    await dbHelper.getPaymentMethod();
    if (this.mounted) { // check whether the state object is in tree
      setState(() {
        _paymentMethods = listPaymentMethod;
      });
    }
  }

  Widget _buildApBar() {
    return AppBar(
      title: Text('Nguồn tiền'),
      actions: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _paymentMethodController.text = '';
              _balanceController.text = '';
              _showDialogAction(_paymentMethodController, _balanceController,
                      () => _insertPaymentMethod());
            })
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      color: Color(0xFFF2F3F5),
      child: _buildListView(),
    );
  }

  Widget _buildItemPaymentMethod(PaymentMethod paymentMethod) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(30.0),
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0, 2),
                  blurRadius: 1,
                  spreadRadius: 1)
            ],
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(paymentMethod.methodName,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số dư: ',
                    style: TextStyle(color: Color(0xFF828284), fontSize: 20)),
                Text(
                    NumberFormat.simpleCurrency(locale: 'vi')
                        .format(paymentMethod.balance ?? 0),
                    style: TextStyle(color: Colors.green, fontSize: 20))
              ],
            )
          ],
        ));
  }

  _insertPaymentMethod() async {
    Navigator.pop(context);

    if (_paymentMethodController.text.length > 0 &&
        _balanceController.text.length > 0) {
      final PaymentMethod paymentMethod = PaymentMethod(
          methodName: _paymentMethodController.text,
          balance: double.parse(
              _balanceController.text.replaceAll(new RegExp(r','), '')));
      await dbHelper.insertPaymentMethod(paymentMethod);
      _getPaymentMethod();
    } else {
      _handleShowError();
    }

  }

  _updatePaymentMethod(id) async {
    Navigator.pop(context);

    if (_paymentMethodController.text != null &&
        _balanceController.text != null) {
      final PaymentMethod paymentMethod = PaymentMethod(
          id: id,
          methodName: _paymentMethodController.text,
          balance: double.parse(
              _balanceController.text.replaceAll(new RegExp(r','), '')));
      await dbHelper.updatePaymentMethod(paymentMethod);
      _getPaymentMethod();
    } else {
      _handleShowError();
    }

  }

  _showDialogAction(TextEditingController paymentMethodController,
      TextEditingController balanceController, VoidCallback onPressed) async {
    await showDialog<String>(
      context: context,
      child: AlertDialog(

        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          child: Column(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: paymentMethodController,
                  autofocus: true,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: 'Nguồn tiền',
                      border: InputBorder.none
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(17),
                    ThousandsFormatter()
                  ],
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: 'Số dư',
                      suffixText: 'đ',
                      border: InputBorder.none,
                      suffixStyle: TextStyle(color: Colors.green)),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
              child: const Text(
                'Hủy',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: onPressed,
          )
        ],
      ),
    );
  }

  Widget _buildRowItemPaymentMethod(PaymentMethod paymentMethod) {
    return Slidable(
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: _buildItemPaymentMethod(paymentMethod),
      secondaryActions: [
        IconSlideAction(
            color: Color(0xFFFAFAFA),
            icon: Icons.edit,
            foregroundColor: Colors.blue,
            onTap: () {
              _paymentMethodController.text = paymentMethod.methodName;
              _balanceController.text = paymentMethod.balance.toInt().toString();
              _showDialogAction(_paymentMethodController, _balanceController,
                      () => _updatePaymentMethod(paymentMethod.id));
            }),
        IconSlideAction(
          color: Color(0xFFFAFAFA),
          icon: Icons.delete,
          foregroundColor: Colors.red,
          onTap: () => _handleDelete(paymentMethod.id),
        ),
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
                await dbHelper.deletePaymentMethod(id);
                _getPaymentMethod();
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

  Widget _buildListView() {
    return Scrollbar(
      thickness: 5.0,
      child: ListView.builder(
        itemCount: _paymentMethods.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) =>
            _buildRowItemPaymentMethod(_paymentMethods[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildApBar(),
      body: _buildBody(),
    );
  }
}
