class GetAllFilters {
  String? status;
  String? message;
  Data? data;
  Counts? counts;

  GetAllFilters({this.status, this.message, this.data, this.counts});

  GetAllFilters.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    counts = json['counts'] != null ? Counts.fromJson(json['counts']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['message'] = message;
    if (data != null) map['data'] = data!.toJson();
    if (counts != null) map['counts'] = counts!.toJson();
    return map;
  }
}

// =======================================================

class Data {
  List<Companies>? companies;
  List<Zones>? zones;
  List<Branches>? branches;
  List<Departments>? departments;
  List<CtcRanges>? ctcRanges;
  List<PunchOptions>? punchOptions;

  Data({
    this.companies,
    this.zones,
    this.branches,
    this.departments,
    this.ctcRanges,
    this.punchOptions,
  });

  Data.fromJson(Map<String, dynamic> json) {
    companies =
        (json['companies'] as List?)
            ?.map((e) => Companies.fromJson(e))
            .toList();

    zones = (json['zones'] as List?)?.map((e) => Zones.fromJson(e)).toList();

    branches =
        (json['branches'] as List?)?.map((e) => Branches.fromJson(e)).toList();

    departments =
        (json['departments'] as List?)
            ?.map((e) => Departments.fromJson(e))
            .toList();

    ctcRanges =
        (json['ctc_ranges'] as List?)
            ?.map((e) => CtcRanges.fromJson(e))
            .toList();

    punchOptions =
        (json['punch_options'] as List?)
            ?.map((e) => PunchOptions.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (companies != null) {
      map['companies'] = companies!.map((e) => e.toJson()).toList();
    }
    if (zones != null) {
      map['zones'] = zones!.map((e) => e.toJson()).toList();
    }
    if (branches != null) {
      map['branches'] = branches!.map((e) => e.toJson()).toList();
    }
    if (departments != null) {
      map['departments'] = departments!.map((e) => e.toJson()).toList();
    }
    if (ctcRanges != null) {
      map['ctc_ranges'] = ctcRanges!.map((e) => e.toJson()).toList();
    }
    if (punchOptions != null) {
      map['punch_options'] = punchOptions!.map((e) => e.toJson()).toList();
    }
    return map;
  }
}

// =======================================================

class Companies {
  String? cmpid;
  String? cmpname;

  Companies({this.cmpid, this.cmpname});

  Companies.fromJson(Map<String, dynamic> json) {
    cmpid = json['cmpid']?.toString();
    cmpname = json['cmpname'];
  }

  Map<String, dynamic> toJson() {
    return {'cmpid': cmpid, 'cmpname': cmpname};
  }
}

// =======================================================

class Zones {
  String? id;
  String? name;

  Zones({this.id, this.name});

  Zones.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// =======================================================

class Branches {
  String? id;
  String? name;
  String? zoneId;

  Branches({this.id, this.name, this.zoneId});

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
    zoneId = json['zone_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'zone_id': zoneId};
  }
}

// =======================================================

class Departments {
  String? departmentId;
  String? departmentName;
  List<Designations>? designations;

  Departments({this.departmentId, this.departmentName, this.designations});

  Departments.fromJson(Map<String, dynamic> json) {
    departmentId = json['department_id']?.toString();
    departmentName = json['department_name'];
    designations =
        (json['designations'] as List?)
            ?.map((e) => Designations.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': departmentId,
      'department_name': departmentName,
      'designations': designations?.map((e) => e.toJson()).toList(),
    };
  }
}

// =======================================================

class Designations {
  String? designationsId;
  String? designations;

  Designations({this.designationsId, this.designations});

  Designations.fromJson(Map<String, dynamic> json) {
    designationsId = json['designations_id']?.toString();
    designations = json['designations'];
  }

  Map<String, dynamic> toJson() {
    return {'designations_id': designationsId, 'designations': designations};
  }
}

// =======================================================

class CtcRanges {
  String? value;
  String? label;

  CtcRanges({this.value, this.label});

  CtcRanges.fromJson(Map<String, dynamic> json) {
    value = json['value']?.toString();
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'label': label};
  }
}

// =======================================================

class PunchOptions {
  String? id;
  String? name;

  PunchOptions({this.id, this.name});

  PunchOptions.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

// =======================================================

class Counts {
  int? companies;
  int? zones;
  int? branches;
  int? departments;

  Counts({this.companies, this.zones, this.branches, this.departments});

  Counts.fromJson(Map<String, dynamic> json) {
    companies = json['companies'];
    zones = json['zones'];
    branches = json['branches'];
    departments = json['departments'];
  }

  Map<String, dynamic> toJson() {
    return {
      'companies': companies,
      'zones': zones,
      'branches': branches,
      'departments': departments,
    };
  }
}
