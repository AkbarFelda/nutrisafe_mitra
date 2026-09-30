import '../domain/allergy_monitoring.dart';

final sampleAllergyMonitoring = AllergyMonitoringData([
  SchoolAllergyData(
    name: 'SDN 1 Subang',
    students: 187,
    studentAllergies: [
      for (var i = 0; i < 4; i++) {StudentAllergy.peanut},
      for (var i = 0; i < 2; i++) {StudentAllergy.egg},
      {StudentAllergy.milk},
    ],
  ),
  SchoolAllergyData(
    name: 'SMPN 1 Subang',
    students: 340,
    studentAllergies: [
      for (var i = 0; i < 6; i++) {StudentAllergy.peanut},
      for (var i = 0; i < 3; i++) {StudentAllergy.egg},
      for (var i = 0; i < 3; i++) {StudentAllergy.milk},
    ],
  ),
]);
