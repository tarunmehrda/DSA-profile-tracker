class UserProfile {
  final String id;
  final String email;
  final String name;
  final String? token;
  final String? leetcodeUsername;
  final String? codeforcesUsername;
  final String? codechefUsername;
  final String? gfgUsername;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.token,
    this.leetcodeUsername,
    this.codeforcesUsername,
    this.codechefUsername,
    this.gfgUsername,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      token: json['token'],
      leetcodeUsername: json['leetcodeUsername'],
      codeforcesUsername: json['codeforcesUsername'],
      codechefUsername: json['codechefUsername'],
      gfgUsername: json['gfgUsername'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'leetcodeUsername': leetcodeUsername,
      'codeforcesUsername': codeforcesUsername,
      'codechefUsername': codechefUsername,
      'gfgUsername': gfgUsername,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? leetcodeUsername,
    String? codeforcesUsername,
    String? codechefUsername,
    String? gfgUsername,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      leetcodeUsername: leetcodeUsername ?? this.leetcodeUsername,
      codeforcesUsername: codeforcesUsername ?? this.codeforcesUsername,
      codechefUsername: codechefUsername ?? this.codechefUsername,
      gfgUsername: gfgUsername ?? this.gfgUsername,
    );
  }
}
