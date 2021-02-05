
import 'package:flutter/material.dart';
import 'package:money_lover/page/categories_expense_page.dart';
import 'package:money_lover/page/expense_page.dart';
import 'package:money_lover/page/payment_method_page.dart';
import 'package:money_lover/page/report_expense_page.dart';

class ExpenseApp extends StatefulWidget {
  @override
  _ExpenseAppState createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  int _selectedIndex = 0;

  final List<Widget> _children = [
    ExpensePage(),
    CategoriesPage(),
    ReportExpansePage(),
    PaymentMethodPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavigationBar(){
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey,width: 0.5)
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Color(0xFF2d2d2e),
        backgroundColor: Color(0xFFFAFAFA),
        showSelectedLabels: true,
        showUnselectedLabels: true,

        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money,size: 25,),
            label: 'Thu chi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category,size: 25,),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart,size: 25,),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_sharp,size: 25,),
            label: 'Nguồn tiền',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}