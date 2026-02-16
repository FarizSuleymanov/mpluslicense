import 'dart:convert';

String filtersToJson(Filters data) => json.encode(data.toJson());

class Filters {
  Pager? pager;
  int status;
  List<FilterConditions> filterConditions;

  Filters({
    this.pager,
    required this.status,
    required this.filterConditions,
  });

  Map<String, dynamic> toJson() => {
        "pager": pager!.toJson(),
        "status": status,
        "filterConditions":
            List<dynamic>.from(filterConditions.map((x) => x.toJson())),
      };

  Map<String, dynamic> toJsonWithoutPager() => {
        "status": status,
        "filterConditions":
            List<dynamic>.from(filterConditions.map((x) => x.toJson())),
      };
}

class FilterConditions {
  bool isUsed;
  String columnName;
  String condition;
  String valueX;
  String valueY;

  FilterConditions({
    required this.isUsed,
    required this.columnName,
    required this.condition,
    required this.valueX,
    required this.valueY,
  });

  factory FilterConditions.fromJson(Map<String, dynamic> json) =>
      FilterConditions(
        isUsed: json["isUsed"],
        columnName: json["columnName"],
        condition: json["condition"],
        valueX: json["valueX"],
        valueY: json["valueY"],
      );

  Map<String, dynamic> toJson() => {
        "isUsed": isUsed,
        "columnName": columnName,
        "condition": condition,
        "valueX": valueX,
        "valueY": valueY,
      };
}

class Pager {
  int pageNumber;
  int pageSize;

  Pager({
    required this.pageNumber,
    required this.pageSize,
  });

  factory Pager.fromJson(Map<String, dynamic> json) => Pager(
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
      );

  Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "pageSize": pageSize,
      };
}
