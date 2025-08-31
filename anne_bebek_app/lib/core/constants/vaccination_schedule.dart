class VaccinationInfo {
  final String name;
  final String description;
  final int dueMonth;
  final String details;

  VaccinationInfo({
    required this.name,
    required this.description,
    required this.dueMonth,
    required this.details,
  });
}

final List<VaccinationInfo> standardVaccinationSchedule = [
  VaccinationInfo(
    name: 'Hepatit B (1. Doz)',
    description: 'Hepatit B Aşısı',
    dueMonth: 0,
    details: 'Doğumdan sonraki ilk 72 saat içinde yapılır.',
  ),
  VaccinationInfo(
    name: 'Hepatit B (2. Doz)',
    description: 'Hepatit B Aşısı',
    dueMonth: 1,
    details: 'İlk dozdan 1 ay sonra yapılır.',
  ),
  VaccinationInfo(
    name: 'DaBT-İPA-Hib (1. Doz)',
    description:
        '5\'li Karma Aşı (Difteri, Boğmaca, Tetanoz, Polio, Hemofilus İnfluenza Tip B)',
    dueMonth: 2,
    details: '2. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'KPA (1. Doz)',
    description: 'Pnömokok (Zatürre) Aşısı',
    dueMonth: 2,
    details: '2. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'DaBT-İPA-Hib (2. Doz)',
    description: '5\'li Karma Aşı',
    dueMonth: 4,
    details: '4. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'KPA (2. Doz)',
    description: 'Pnömokok (Zatürre) Aşısı',
    dueMonth: 4,
    details: '4. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'DaBT-İPA-Hib (3. Doz)',
    description: '5\'li Karma Aşı',
    dueMonth: 6,
    details: '6. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'OPA (1. Doz)',
    description: 'Oral Polio (Çocuk Felci) Aşısı',
    dueMonth: 6,
    details: '6. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'Hepatit B (3. Doz)',
    description: 'Hepatit B Aşısı',
    dueMonth: 6,
    details: '6. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'KPA (Pekiştirme Dozu)',
    description: 'Pnömokok (Zatürre) Aşısı',
    dueMonth: 12,
    details: '12. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'KKK (1. Doz)',
    description: 'Kızamık, Kızamıkçık, Kabakulak Aşısı',
    dueMonth: 12,
    details: '12. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'Suçiçeği (1. Doz)',
    description: 'Suçiçeği Aşısı',
    dueMonth: 12,
    details: '12. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'DaBT-İPA-Hib (Pekiştirme Dozu)',
    description: '5\'li Karma Aşı',
    dueMonth: 18,
    details: '18. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'OPA (2. Doz)',
    description: 'Oral Polio (Çocuk Felci) Aşısı',
    dueMonth: 18,
    details: '18. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'Hepatit A (1. Doz)',
    description: 'Hepatit A Aşısı',
    dueMonth: 24,
    details: '24. ayın sonunda yapılır.',
  ),
  VaccinationInfo(
    name: 'Hepatit A (2. Doz)',
    description: 'Hepatit A Aşısı',
    dueMonth: 30,
    details: 'İlk dozdan 6 ay sonra yapılır.',
  ),
  VaccinationInfo(
    name: 'KKK (Pekiştirme Dozu)',
    description: 'Kızamık, Kızamıkçık, Kabakulak Aşısı',
    dueMonth: 48,
    details: '4-6 yaş arasında (ilkokul öncesi) yapılır.',
  ),
  VaccinationInfo(
    name: 'DaBT-İPA (Pekiştirme Dozu)',
    description: '4\'lü Karma Aşı (Difteri, Boğmaca, Tetanoz, Polio)',
    dueMonth: 48,
    details: '4-6 yaş arasında (ilkokul öncesi) yapılır.',
  ),
];
