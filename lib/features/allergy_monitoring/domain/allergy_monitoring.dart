enum StudentAllergy {
  peanut('Alergi Kacang'),
  egg('Alergi Telur'),
  milk('Alergi Susu');

  const StudentAllergy(this.label);
  final String label;
}

class SchoolAllergyData {
  const SchoolAllergyData({
    required this.name,
    required this.students,
    required this.studentAllergies,
  });
  final String name;
  final int students;
  // One entry per student; a student can have more than one allergy.
  final List<Set<StudentAllergy>> studentAllergies;
  int get allergicStudents =>
      studentAllergies.where((allergies) => allergies.isNotEmpty).length;
  double get allergyRate => students == 0 ? 0 : allergicStudents / students;
}

class AllergyMonitoringData {
  const AllergyMonitoringData(this.schools, {this.breakdown = const {}});
  final List<SchoolAllergyData> schools;
  final Map<StudentAllergy, int> breakdown;
  int count(StudentAllergy allergy) =>
      breakdown[allergy] ??
      schools.fold(
        0,
        (total, school) =>
            total +
            school.studentAllergies
                .where((allergies) => allergies.contains(allergy))
                .length,
      );
  int get allergicStudents =>
      schools.fold(0, (total, school) => total + school.allergicStudents);
  List<StudentAllergy> get types =>
      StudentAllergy.values.where((type) => count(type) > 0).toList();
  int get totalAllergies =>
      StudentAllergy.values.fold(0, (total, type) => total + count(type));
}

String allergyPercentage(double value) =>
    '${(value * 100).toStringAsFixed(2).replaceAll('.', ',')}%';
