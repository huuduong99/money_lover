import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_lover/database/database_helper.dart';
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
  List<Expense> expenses = <Expense>[];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  void loadExpenses() async{
    final List<Expense> listExpense = await dbHelper.getExpenses();
    setState(() {
      expenses = listExpense;
    });
  }

  _handleDelete(int id){
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Xác nhận"),
        content: Text('Bạn có chắc chắn muốn xóa ?'),
        actions: [
          FlatButton(
              onPressed: () async {
                await dbHelper.deleteExpense(id);
                loadExpenses();
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

  Widget _buildItem(Expense expense){
    return Container(
      margin: EdgeInsets.symmetric(vertical:5,horizontal: 5),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF936fdc),
              Color(0xFFd17ef2),
            ],
          ),
        boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0,2),
            blurRadius: 1,
            spreadRadius: 1
        )],
        borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(expense.expenseContent.toString(),style: TextStyle(color: Colors.white,fontSize: 20),),
             const SizedBox(height: 10),
             Text(expense.amount.toString()+' VND',style: TextStyle(color: Colors.white,fontSize: 15),),
             const SizedBox(height: 5),
             Text(expense.date.toString(),style: TextStyle(color: Colors.white,fontSize: 15),)
           ],
          ),
          Align(
            alignment: Alignment.center,
              child: Text(expense.type == 1 ? "Thu vào ": "Chi ra",
                style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }

  Widget _buildRowItem(Expense expense){
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateExpensePage(
                    expenseDetail: expense,
                  ),
                )).then((value){
                loadExpenses();
              });
            }
        ),
        IconSlideAction(
          color: Color(0xFFFAFAFA),
          icon: Icons.delete,
          foregroundColor: Colors.red,
          onTap: () =>_handleDelete(expense.id),
        ),
      ],
    );
  }

  Widget _buildListView(){
    return Scrollbar(
      thickness: 5.0,
      child: ListView.builder(
        itemCount: expenses.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) =>_buildRowItem(expenses[index]),
      ),
    );
  }

  Widget _buildBody(){
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: _buildListView(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thu chi'),backgroundColor: Color(0xFF936fdc),centerTitle: true,),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InsertExpensePage())).then((value){
            loadExpenses();
          });
        },
        child: Icon(Icons.add,color: Color(0xFF936fdc),size: 30),
        backgroundColor: Colors.white,
      ),
    );
  }
}
