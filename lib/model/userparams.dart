class UserParams {
  UserParams({
    required this.userToken,
    required this.userUID,
    required this.userFullName,
    required this.userRoll,
    required this.userCompanyName,
    required this.serverName,
  });

  late final String userToken;
  late final String userUID;
  late final String userFullName;
  late final int userRoll;
  late final String userCompanyName;
  late final String serverName;

  factory UserParams.fromJson(Map<String, dynamic> json) => UserParams(
        userToken: json["userToken"],
        userUID: json["userUID"],
        userCompanyName: json["userCompanyName"],
        userFullName: json["userFullName"],
        userRoll: json["userRoll"],
        serverName: json["serverName"],
      );

  Map<String, dynamic> toJson() => {
        "userToken": userToken,
        "userUID": userUID,
        "userCompanyName": userCompanyName,
        "userFullName": userFullName,
        "userRoll": userRoll,
        "serverName": serverName
      };
}

