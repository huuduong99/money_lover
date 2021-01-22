import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/page/select_parent_category_expense_page.dart';


class InsertCategoryExpensePage extends StatefulWidget {
  @override
  _InsertCategoryExpensePageState createState() => _InsertCategoryExpensePageState();
}

class _InsertCategoryExpensePageState extends State<InsertCategoryExpensePage> {
  static DBHelper dbHelper = DBHelper();
  TextEditingController _categoryNameController = TextEditingController();
  Category _category ;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildInputText(TextEditingController controller,int maxLines ,TextInputType inputType, bool formatter, String hint){
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: Colors.black,
      keyboardType: inputType,
      inputFormatters: !formatter ? null : <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      decoration: new InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hint),
    );
  }

  Widget _buildButtonExit(){
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

  Widget _buildButtonSave(){
    return RawMaterialButton(
      onPressed: () => _handleSaveNewCategory(),
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

  _handleSaveNewCategory() async{
    try{

      if(_categoryNameController.text.length > 0){

        final Category category = Category(
          name: _categoryNameController.text,
          parentId: _category != null ? _category.id : null,
        );
        await dbHelper.insertCategories(category);
        Navigator.pop(context);
      }
      else{
        _handleShowError();
      }
    }catch(e){
      _handleShowError();
    }
  }

  _handleShowError(){
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

  Widget _buildParentGroup() {
    return Padding(
      padding: EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Nhóm cha'),
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
                                SelectParentCategoryExpensePage(null))).then((result) {
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
          margin: EdgeInsets.only(left: 20, top: 50, right: 30, bottom: 200),
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
                    Text('Thêm danh mục', style: TextStyle(fontSize: 25, color: Colors.blue)),
                    const Divider(),
                    _buildInputText(_categoryNameController, 3, TextInputType.text, false, 'Tên danh mục'),
                    const Divider(),
                    _buildParentGroup(),
                    const Divider(),
                  ],
                ),
              ),
              Positioned(
                  top: -20,
                  right: -40,
                  child: _buildButtonExit()),
              Positioned(
                  bottom: -30,
                  left: 10,
                  right: 10,
                  child: _buildButtonSave()),
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
