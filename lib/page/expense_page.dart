import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/model/expense_model.dart';
import 'package:money_lover/page/insert_expense_page.dart';
import 'package:money_lover/page/update_expense_page.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final SlidableController _slidableController = SlidableController();
  static DBHelper dbHelper = DBHelper();
  List<Expense> _expenses = <Expense>[];
  List<Category> _categories = <Category>[];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() async {
    final List<Expense> listExpense = await dbHelper.getExpenses();
    final List<Category> listCategory = await dbHelper.getCategories();
    setState(() {
      _expenses = listExpense;
      _categories = listCategory;
    });
  }

  String _getNameCategory(int id) {

    for(var record in _categories){
      if(record.id == id){
        return record.name;
      }
    }
    return '';

  }


  Widget _buildAppBar(){
    return AppBar(
      title: Text('Thu chi'),
      backgroundColor: Colors.blue,
      actions: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsertExpensePage())).then((value) {
                _loadExpenses();
              });
            })
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
                _loadExpenses();
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



  Widget _buildItem(Expense expense) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
                color: Colors.grey,
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
                Text(expense.expenseContent.toString(),
                    style: TextStyle(color: Colors.blueAccent, fontSize: 20,fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Danh mục: '+ (expense.categoryId != null ? _getNameCategory(expense.categoryId) : ''),
                  style: TextStyle(color: Color(0xFF48484A),fontSize: 16,fontWeight: FontWeight.bold),),
                const SizedBox(height: 5),
                Text('Ngày: ' +expense.date.toString(),
                    style: TextStyle(color: Color(0xFF828284), fontSize: 13,fontWeight: FontWeight.bold))
              ],
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  expense.type == 1
                      ? Text('+',style: TextStyle(color: Colors.green))
                      : Text("-",style: TextStyle(color: Colors.red)),
                  Text(
                      FlutterMoneyFormatter(amount: expense.amount)
                          .output
                          .withoutFractionDigits
                          .toString(),
                      style: TextStyle(color: expense.type == 1 ? Colors.green : Colors.red, fontSize: 15,fontWeight:FontWeight.bold)),
                ],
              )
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
                _loadExpenses();
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
      color: Color(0xFFF2F3F5),
      width: double.infinity,
      child: _buildListView(),
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
