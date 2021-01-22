import 'package:flutter/material.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';

class SelectCategoryExpensePage extends StatefulWidget {
  @override
  _SelectCategoryExpensePageState createState() =>
      _SelectCategoryExpensePageState();
}

class _SelectCategoryExpensePageState
    extends State<SelectCategoryExpensePage> {
  static DBHelper dbHelper = DBHelper();
  List<Category> _parentCategories = <Category>[];
  List<Category> _childrenCategory = <Category>[];

  @override
  void initState() {
    super.initState();
    _getCategory();
  }

  _getCategory() async {
    final List<Category> listParentCategory =
    await dbHelper.getAllParentCateGory(null);
    final List<Category> _children = await dbHelper.getAllChildrenCategory();

    setState(() {
      _parentCategories = listParentCategory;
      _childrenCategory = _children;
    });
  }

  Widget _buildRowItem(Category category) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context, category);
      },
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Color(0xFFE9F6EC),
                        borderRadius: BorderRadius.circular(50.0)),
                    child: Text(
                      category.name[0],
                      style: TextStyle(color: Color(0xFF28A745),fontWeight: FontWeight.bold,fontSize: 18),
                    ),
                    width: 50.0,
                    height: 50.0,
                  ),
                  SizedBox(width: 15.0),
                  Text(category.name, style: TextStyle(fontSize: 18.0,color: Color(0xFF2C333A))),
                ],
              ),
              const Divider(color: Colors.grey,thickness: 0.2)
            ],
          )),
    );
  }

  Widget _buildExpansionTile(Category category) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent,accentColor: Colors.green),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ExpansionTile(
            childrenPadding: EdgeInsets.only(left: 40.0),
            title: GestureDetector(
              onTap: (){
                Navigator.pop(context,category);
              },
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50.0)),
                    width: 50.0,
                    height: 50.0,
                    child: Center(
                        child: Text(
                          category.name[0],
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),
                        )),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
            children: _childrenCategory
                .where((item) => item.parentId == category.id)
                .map((item) => _buildRowItem(item))
                .toList() //nếu là con mới build
        ),
      ),
    );
  }

  Widget _buildApBar() {
    return AppBar(
      title: Text('Chọn danh mục'),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Color(0xFFFFFFFF),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 10),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
            children: _parentCategories
                .map((item) => _buildExpansionTile(item))
                .toList()),
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
