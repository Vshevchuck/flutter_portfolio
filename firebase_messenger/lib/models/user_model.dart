class UserModel{
  final String name;
  final String email;
  final String id;
  UserModel({required this.name, required this.email,required this.id});
  factory UserModel.fromJson(Map<String,dynamic> json)
  {
    return UserModel(name: json['name'],email : json['email'],id: json['id']);
  }
}

/// Model for register and login user
class UserAuth {
  final String? name;
  final String email;
  final String password;
  UserAuth({this.name, required this.email, required this.password});
}