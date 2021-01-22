class Category {
  final int id;
  final String name;
  final int parentId;


  Category({this.id, this.name, this.parentId});

  factory Category.fromMap(Map<String, dynamic> map){
    return Category(
        id: map['id'],
        name: map['category_name'],
        parentId: map['parent_id']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_name': name,
      'parent_id': parentId
    };
  }

}