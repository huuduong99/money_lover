import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/page/insert_category_expense_page.dart';
import 'package:money_lover/page/update_category_expense_page.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategotiesScreenState createState() => _CategotiesScreenState();
}

class _CategotiesScreenState extends State<CategoriesPage> {
  static DBHelper dbHelper = DBHelper();
  List<Category> _categories = <Category>[];
  final SlidableController _slidableController = SlidableController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    final List<Category> listCategory = await dbHelper.getCategories();

    if (this.mounted) { // check whether the state object is in tree
      setState(() {
        _categories = listCategory;
      });
    }

  }


  _checkCategoryHaveChildren(int categoryId) async{
    final List<Category> categories = await dbHelper.getChildrenOfCategory(categoryId);

    if(categories.length > 0){
      return true;
    }
    return false;
  }

  String _getNameCategory(int id) {
    for (var record in _categories) {
      if (record.id == id) {
        return record.name;
      }
    }
    return '';
  }

  _handleShowNotification(String title, String content){
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
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

  _handleDelete(int id) {
    return showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Xác nhận"),
        content: Text('Bạn có chắc chắn muốn xóa ?'),
        actions: [
          FlatButton(
              onPressed: () async {
                final bool isParent = await _checkCategoryHaveChildren(id);
                Navigator.pop(context);

                if(!isParent){
                  await dbHelper.deleteCategory(id);
                  loadCategories();
                }
                else{
                  _handleShowNotification('Lỗi', 'Không xóa được vì nó đang là danh mục cha');
                }
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

  Widget _buildItem(Category category) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: EdgeInsets.all(30.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name,
                style: TextStyle(color: Colors.blue, fontSize: 25,fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 10,
            ),
            Text(
                'Nhóm cha: ' +
                    (category.parentId != null
                        ? _getNameCategory(category.parentId)
                        : 'Không có'),
                style: TextStyle(color: Color(0xFF828284), fontSize: 15))
          ],
        ));
  }

  Widget _buildRowItem(Category category) {
    return Slidable(
      controller: _slidableController,
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: _buildItem(category),
      secondaryActions: [
        IconSlideAction(
            color: Color(0xFFFAFAFA),
            icon: Icons.edit,
            foregroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UpdateCategoryExpensePage(category: category),
                  )).then((value) {
                loadCategories();
              });
            }),
        IconSlideAction(
          color: Color(0xFFFAFAFA),
          icon: Icons.delete,
          foregroundColor: Colors.red,
          onTap: () => _handleDelete(category.id),
        ),
      ],
    );
  }

  Widget _buildListViewCategory() {
    return Scrollbar(
      thickness: 5.0,
      child: ListView.builder(
        itemCount: _categories.length,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) =>
            _buildRowItem(_categories[index]),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
        color: Color(0xFFF2F3F5),
        width: double.infinity,
        child: _buildListViewCategory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh mục thu chi'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InsertCategoryExpensePage())).then((value) {
                  loadCategories();
                });
              })
        ],
      ),
      body: _buildBody(),
    );
  }
}
