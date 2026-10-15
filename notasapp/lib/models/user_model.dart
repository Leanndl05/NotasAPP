class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final bool isDemo;

  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.isDemo = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'isDemo': isDemo,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String?,
        isDemo: json['isDemo'] as bool? ?? false,
      );
}
