class UserDataModel {
  const UserDataModel({
    required this.uid,
    this.isProUser = false,
  });

  final String uid;
  final bool isProUser;

  UserDataModel copyWith({String? uid, bool? isProUser}) {
    return UserDataModel(
      uid: uid ?? this.uid,
      isProUser: isProUser ?? this.isProUser,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'isProUser': isProUser,
      };

  factory UserDataModel.fromMap(Map<String, dynamic>? map, {String uid = ''}) {
    final values = map ?? const <String, dynamic>{};
    return UserDataModel(
      uid: values['uid'] as String? ?? uid,
      isProUser: values['isProUser'] as bool? ?? false,
    );
  }
}