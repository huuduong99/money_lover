import 'package:flutter/material.dart';
import 'package:money_lover/page/categories_expense_page.dart';
import 'package:money_lover/page/expense_page.dart';
import 'package:money_lover/page/report_expense_page.dart';
import 'package:money_lover/page/settings_expense_page.dart';

import 'page/expense_page.dart';


void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: ExpenseApp(),
  ));
}


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
    SettingsExpansePage(),
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
        showSelectedLabels: true,
        showUnselectedLabels: true,

        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money,color: Colors.black,),
            activeIcon: Icon(Icons.attach_money,color: Colors.blue),
            label: 'Thu chi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category,color: Colors.black,),
            activeIcon: Icon(Icons.category,color: Colors.blue),
            label: 'Danh mục',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart,color: Colors.black),
            activeIcon: Icon(Icons.bar_chart,color: Colors.blue),
            label: 'Báo cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Colors.black,),
            activeIcon: Icon(Icons.settings,color: Colors.blue),
            label: 'Cài đặt',
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