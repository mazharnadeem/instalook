import 'dart:io';
import 'dart:typed_data';

class UserModel {
  final String name;
  final String email;
  final int age;
  UserModel(this.name, this.email, this.age);
  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'age': age};
  }
}

class Photo {
  int? id;
  String? photo_name;

  Photo(this.id, this.photo_name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'photo_name': photo_name,
    };
    return map;
  }

  Photo.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    photo_name = map['photo_name'];
  }
}

class Picture {
  String? picture;

  Picture({required this.picture});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'photo_name': picture,
    };
    return map;
  }

  Picture.fromMap(Map<String, dynamic> map) {
    picture = map['photo_name'];
  }
  // Picture.fromMap(Map map, this.title, this.picture) {
  //   title = map[title];
  //   picture = map[picture];
  // }

  // Map<String, dynamic> toMap() => {
  //       "title": title,
  //       "picture": picture,
  //     };
}
