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

/* ---------------- DATA ---------------- */

class Data {
  List<Companies>? companies;
  List<Zones>? zones;
  List<Branches>? branches;
  List<Departments>? departments;
  List<Employees>? employees;
  List<CtcRanges>? ctcRanges;
  List<PunchOptions>? punchOptions; // ✅ Fixed

  Data({
    this.companies,
    this.zones,
    this.branches,
    this.departments,
    this.employees,
    this.ctcRanges,
    this.punchOptions,
  });

  Data.fromJson(Map<String, dynamic> json) {
    if (json['companies'] != null) {
      companies = [];
      json['companies'].forEach((v) {
        companies!.add(Companies.fromJson(v));
      });
    }

    if (json['zones'] != null) {
      zones = [];
      json['zones'].forEach((v) {
        zones!.add(Zones.fromJson(v));
      });
    }

    if (json['branches'] != null) {
      branches = [];
      json['branches'].forEach((v) {
        branches!.add(Branches.fromJson(v));
      });
    }

    if (json['departments'] != null) {
      departments = [];
      json['departments'].forEach((v) {
        departments!.add(Departments.fromJson(v));
      });
    }

    if (json['employees'] != null) {
      employees = [];
      json['employees'].forEach((v) {
        employees!.add(Employees.fromJson(v));
      });
    }

    if (json['ctc_ranges'] != null) {
      ctcRanges = [];
      json['ctc_ranges'].forEach((v) {
        ctcRanges!.add(CtcRanges.fromJson(v));
      });
    }

    if (json['punch_options'] != null) {
      punchOptions = [];
      json['punch_options'].forEach((v) {
        punchOptions!.add(PunchOptions.fromJson(v)); // ✅ Fixed
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};

    if (companies != null)
      map['companies'] = companies!.map((v) => v.toJson()).toList();
    if (zones != null) map['zones'] = zones!.map((v) => v.toJson()).toList();
    if (branches != null)
      map['branches'] = branches!.map((v) => v.toJson()).toList();
    if (departments != null)
      map['departments'] = departments!.map((v) => v.toJson()).toList();
    if (employees != null)
      map['employees'] = employees!.map((v) => v.toJson()).toList();
    if (ctcRanges != null)
      map['ctc_ranges'] = ctcRanges!.map((v) => v.toJson()).toList();
    if (punchOptions != null)
      map['punch_options'] = punchOptions!.map((v) => v.toJson()).toList();

    return map;
  }
}

/* ---------------- MODELS ---------------- */

class Companies {
  String? cmpid;
  String? cmpname;

  Companies({this.cmpid, this.cmpname});

  Companies.fromJson(Map<String, dynamic> json) {
    cmpid = json['cmpid'];
    cmpname = json['cmpname'];
  }

  Map<String, dynamic> toJson() => {'cmpid': cmpid, 'cmpname': cmpname};
}

class Zones {
  String? id;
  String? name;

  Zones({this.id, this.name});

  Zones.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Branches {
  String? id;
  String? name;
  String? zoneId;

  Branches({this.id, this.name, this.zoneId});

  Branches.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    zoneId = json['zone_id'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'zone_id': zoneId};
}

class Departments {
  String? departmentId;
  String? departmentName;
  List<Designations>? designations;

  Departments({this.departmentId, this.departmentName, this.designations});

  Departments.fromJson(Map<String, dynamic> json) {
    departmentId = json['department_id'];
    departmentName = json['department_name'];

    if (json['designations'] != null) {
      designations = [];
      json['designations'].forEach((v) {
        designations!.add(Designations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
    'department_id': departmentId,
    'department_name': departmentName,
    'designations': designations?.map((e) => e.toJson()).toList(),
  };
}

class Designations {
  String? designationsId;
  String? designations;

  Designations({this.designationsId, this.designations});

  Designations.fromJson(Map<String, dynamic> json) {
    designationsId = json['designations_id'];
    designations = json['designations'];
  }

  Map<String, dynamic> toJson() => {
    'designations_id': designationsId,
    'designations': designations,
  };
}

class Employees {
  String? fullname;
  String? employmentId;
  String? activated;

  Employees({this.fullname, this.employmentId, this.activated});

  Employees.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'];
    employmentId = json['employment_id'];
    activated = json['activated'];
  }

  Map<String, dynamic> toJson() => {
    'fullname': fullname,
    'employment_id': employmentId,
    'activated': activated,
  };
}

class CtcRanges {
  String? value;
  String? label;

  CtcRanges({this.value, this.label});

  CtcRanges.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
}

/* ---------------- COUNTS ---------------- */

class Counts {
  int? companies;
  int? zones;
  int? branches;
  int? departments;
  int? employees;

  Counts({
    this.companies,
    this.zones,
    this.branches,
    this.departments,
    this.employees,
  });

  Counts.fromJson(Map<String, dynamic> json) {
    companies = json['companies'];
    zones = json['zones'];
    branches = json['branches'];
    departments = json['departments'];
    employees = json['employees'];
  }

  Map<String, dynamic> toJson() => {
    'companies': companies,
    'zones': zones,
    'branches': branches,
    'departments': departments,
    'employees': employees,
  };
}

/* ---------------- PUNCH OPTIONS (MISSING CLASS) ---------------- */

class PunchOptions {
  String? id;
  String? name;

  PunchOptions({this.id, this.name});

  PunchOptions.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
