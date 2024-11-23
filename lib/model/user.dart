class User{
  int user_id;
  String user_name;
  String user_email;
  String user_password;
  String user_phone;
  String user_address;
  String user_type;

  User(this.user_id, this.user_name, this.user_email, this.user_password,this.user_phone,this.user_address, this.user_type);

  factory User.fromJson(Map<String, dynamic> json) => User(
    int.parse(json['user_id']),
    json['user_name'],
    json['user_email'],
    json['user_password'],
    json['user_phone'],
    json['user_address'],
    json['user_type'],
    );

  Map<String, dynamic> toJson() => {
    'user_id' : user_id.toString(),
    'user_name' : user_name,
    'user_email' : user_email,
    'user_password' : user_password,
    'user_phone' : user_phone,
    'user_address' : user_address,
    'user_type' : user_type
  };
}