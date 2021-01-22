import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_lover/database/database_helper.dart';
import 'package:money_lover/model/category_model.dart';
import 'package:money_lover/page/select_parent_category_expense_page.dart';


class UpdateCategoryExpensePage extends StatefulWidget {
  final Category category;

  UpdateCategoryExpensePage({@required this.category});

  @override
  _UpdateCategoryExpensePageState createState() => _UpdateCategoryExpensePageState();
}

class _UpdateCategoryExpensePageState extends State<UpdateCategoryExpensePage> {
  static DBHelper dbHelper = DBHelper();
  TextEditingController _categoryNameController = TextEditingController();
  Category _category ;
  bool _categoryIsParent = false;

  @override
  void initState() {
    super.initState();
    _categoryNameController.text = widget.category.name;
    _getResultParent();
  }

  _getResultParent() async{
    _categoryIsParent = await _checkCategoryHaveChildren(widget.category.id);
  }

  _handleSaveUpdateCategory() async{
    try{

      if(_categoryNameController.text.length > 0){

        final Category category = Category(
          id: widget.category.id,
          name: _categoryNameController.text,
          parentId: _category != null ? _category.id : widget.category.parentId,
        );
        await dbHelper.updateCategory(category);
        Navigator.pop(context);
      }
      else{
        _handleShowNotification('Lỗi','Vui lòng nhập đầy đủ thông tin');
      }
    }catch(e){
      _handleShowNotification('Lỗi','Vui lòng nhập đầy đủ thông tin');
    }
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


  _checkCategoryHaveChildren(int categoryId) async{
    final List<Category> categories = await dbHelper.getChildrenOfCategory(categoryId);

    if(categories.length > 0){
      return true;
    }
    return false;
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
      onPressed: () => _handleSaveUpdateCategory(),
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
                    if(_categoryIsParent == false){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SelectParentCategoryExpensePage(widget.category))).then((result) {
                        if (result != null) {
                          setState(() {
                            _category = result;
                          });
                        }
                      });
                    }
                    else{
                      _handleShowNotification('Lỗi', 'Không thể sửa nhóm cha vì danh muc là danh mục cha');
                    }
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
                    Text('Sửa danh mục', style: TextStyle(fontSize: 25, color: Colors.blue)),
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
