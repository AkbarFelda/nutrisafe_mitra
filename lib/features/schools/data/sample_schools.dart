import '../domain/school.dart';

const sampleSchools = [
  School(
    name: 'SDN 1 Subang',
    address: 'Jl. H.O. Iskandar, Desa No.60, Subang, Kec. Subang, Kabupaten Kuningan, Jawa Barat 45586',
    level: SchoolLevel.elementary,
    students: 187,
    teachers: 9,
    allergies: [
      SchoolAllergy(allergen: SchoolAllergen.peanuts, students: 5),
      SchoolAllergy(allergen: SchoolAllergen.eggs, students: 2),
      SchoolAllergy(allergen: SchoolAllergen.milk, students: 0),
    ],
  ),
  School(
    name: 'SMPN 1 Subang',
    address: 'Jl. Letjen Suprapto No.105, Karanganyar, Kec. Subang, Kabupaten Subang, Jawa Barat 41211',
    level: SchoolLevel.juniorHigh,
    students: 340,
    teachers: 20,
    allergies: [
      SchoolAllergy(allergen: SchoolAllergen.peanuts, students: 5),
      SchoolAllergy(allergen: SchoolAllergen.eggs, students: 3),
      SchoolAllergy(allergen: SchoolAllergen.milk, students: 4),
    ],
  ),
];
