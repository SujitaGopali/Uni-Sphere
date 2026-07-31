/// Nepal colleges list — matches website `lib/colleges.ts`.
const nepalColleges = <String>[
  'Herald College Kathmandu (University of Wolverhampton)',
  'Islington College (London Metropolitan University)',
  'The British College (UWE Bristol / Leeds Beckett)',
  'Softwarica College of IT & E-Commerce (Coventry University)',
  'ISMT College (University of Sunderland)',
  'Patan College for Professional Studies (PCPS - University of Bedfordshire)',
  'LBEF Campus (Asia Pacific University)',
  'Presidential Business School (Westcliff University)',
  'NAMI College (University of Northampton)',
  'Virinchi College (Asia e University)',
  'Texas College of Management and IT (Lincoln University)',
  'Phoenix College of Management (Lincoln University)',
  "King's College (Westcliff University)",
  'IIMS College (UCSI University)',
  'Sunway International Business School (Birmingham City University)',
  'Mid-Valley International College (Help University)',
  'Ritz Hospitality Management College (BHMS)',
];

List<String> getCollegeOptions([String? currentCollege]) {
  final trimmed = currentCollege?.trim();
  if (trimmed == null || trimmed.isEmpty) return List.from(nepalColleges);
  if (nepalColleges.contains(trimmed)) return List.from(nepalColleges);
  return [trimmed, ...nepalColleges];
}
