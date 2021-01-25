import 'package:flutter/material.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';

class SelectParentCategoryExpensePage extends StatefulWidget {
  final Category category;

  SelectParentCategoryExpensePage(this.category);

  @override
  _SelectParentCategoryExpensePageState createState() =>
      _SelectParentCategoryExpensePageState();
}

class _SelectParentCategoryExpensePageState extends State<SelectParentCategoryExpensePage> {
  static DBHelper dbHelper = DBHelper();
  List<Category> _categories = <Category>[];

  @override
  void initState() {
    super.initState();
    _getCategory();
  }

  _getCategory() async{
    int categoryId = widget.category != null ? widget.category.id : null;
    final List<Category> listParentCategory = await dbHelper.getAllParentCateGory(categoryId);
    setState(() {
      _categories = listParentCategory;
    });
  }

  Widget _buildApBar() {
    return AppBar(
      title: Text('Danh mục cha'),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Color(0xFFF2F3F5),
      child: _buildListView(),
    );
  }

  Widget _buildItemCategory(Category category) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, category),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(40.0),
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0, 2),
                  blurRadius: 1,
                  spreadRadius: 1)
            ],
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: Text(category.name,
            style: TextStyle(
                color: Colors.blue, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildListView() {
    return Scrollbar(
      thickness: 5.0,
      child: ListView.builder(
        itemCount: _categories.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) => _buildItemCategory(_categories[index]),
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
