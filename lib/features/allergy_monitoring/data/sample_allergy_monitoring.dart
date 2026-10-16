import '../domain/allergy_monitoring.dart';

final sampleAllergyMonitoring = AllergyMonitoringData([
  SchoolAllergyData(
    name: 'SDN 1 Subang',
    students: 196,
    studentAllergies: [
      for (var i = 0; i < 5; i++) {StudentAllergy.peanut},
      for (var i = 0; i < 4; i++) {StudentAllergy.egg},
    ],
  ),
  SchoolAllergyData(
    name: 'SMPN 1 Subang',
    students: 360,
    studentAllergies: [
      for (var i = 0; i < 5; i++) {StudentAllergy.peanut},
      for (var i = 0; i < 4; i++) {StudentAllergy.egg},
    ],
  ),
]);
