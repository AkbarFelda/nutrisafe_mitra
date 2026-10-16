enum SchoolLevel { elementary, juniorHigh }

enum SchoolAllergen { peanuts, eggs, milk }

class SchoolAllergy {
  const SchoolAllergy({required this.allergen, required this.students});

  final SchoolAllergen allergen;
  final int students;
}

class School {
  const School({
    this.id,
    required this.name,
    required this.address,
    required this.level,
    required this.students,
    required this.teachers,
    this.allergies = const [],
    this.allergyTypes = const [],
  });

  final int? id;
  final String name;
  final String address;
  final SchoolLevel level;
  final int students;
  final int teachers;
  final List<SchoolAllergy> allergies;
  final List<String> allergyTypes;
}
