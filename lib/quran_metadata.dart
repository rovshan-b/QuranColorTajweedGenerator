/// Quran metadata: surah names, juz names, and juz position mappings

/// Surah names in Arabic for headers
const List<String> surahNames = [
  'ٱلْفَاتِحَة', // 1
  'ٱلْبَقَرَة', // 2
  'آلِ عِمْرَان', // 3
  'ٱلنِّسَاء', // 4
  'ٱلْمَائِدَة', // 5
  'ٱلْأَنْعَام', // 6
  'ٱلْأَعْرَاف', // 7
  'ٱلْأَنفَال', // 8
  'ٱلتَّوْبَة', // 9
  'يُونُس', // 10
  'هُود', // 11
  'يُوسُف', // 12
  'ٱلرَّعْد', // 13
  'إِبْرَاهِيم', // 14
  'ٱلْحِجْر', // 15
  'ٱلنَّحْل', // 16
  'ٱلْإِسْرَاء', // 17
  'ٱلْكَهْف', // 18
  'مَرْيَم', // 19
  'طه', // 20
  'ٱلْأَنبِيَاء', // 21
  'ٱلْحَجّ', // 22
  'ٱلْمُؤْمِنُون', // 23
  'ٱلنُّور', // 24
  'ٱلْفُرْقَان', // 25
  'ٱلشُّعَرَاء', // 26
  'ٱلنَّمْل', // 27
  'ٱلْقَصَص', // 28
  'ٱلْعَنكَبُوت', // 29
  'ٱلرُّوم', // 30
  'لُقْمَان', // 31
  'ٱلسَّجْدَة', // 32
  'ٱلْأَحْزَاب', // 33
  'سَبَأ', // 34
  'فَاطِر', // 35
  'يس', // 36
  'ٱلصَّافَّات', // 37
  'ص', // 38
  'ٱلزُّمَر', // 39
  'غَافِر', // 40
  'فُصِّلَتْ', // 41
  'ٱلشُّورَىٰ', // 42
  'ٱلزُّخْرُف', // 43
  'ٱلدُّخَان', // 44
  'ٱلْجَاثِيَة', // 45
  'ٱلْأَحْقَاف', // 46
  'مُحَمَّد', // 47
  'ٱلْفَتْح', // 48
  'ٱلْحُجُرَات', // 49
  'ق', // 50
  'ٱلذَّارِيَات', // 51
  'ٱلطُّور', // 52
  'ٱلنَّجْم', // 53
  'ٱلْقَمَر', // 54
  'ٱلرَّحْمَٰن', // 55
  'ٱلْوَاقِعَة', // 56
  'ٱلْحَدِيد', // 57
  'ٱلْمُجَادِلَة', // 58
  'ٱلْحَشْر', // 59
  'ٱلْمُمْتَحَنَة', // 60
  'ٱلصَّفّ', // 61
  'ٱلْجُمُعَة', // 62
  'ٱلْمُنَافِقُون', // 63
  'ٱلتَّغَابُن', // 64
  'ٱلطَّلَاق', // 65
  'ٱلتَّحْرِيم', // 66
  'ٱلْمُلْك', // 67
  'ٱلْقَلَم', // 68
  'ٱلْحَاقَّة', // 69
  'ٱلْمَعَارِج', // 70
  'نُوح', // 71
  'ٱلْجِنّ', // 72
  'ٱلْمُزَّمِّل', // 73
  'ٱلْمُدَّثِّر', // 74
  'ٱلْقِيَامَة', // 75
  'ٱلْإِنسَان', // 76
  'ٱلْمُرْسَلَات', // 77
  'ٱلنَّبَأ', // 78
  'ٱلنَّازِعَات', // 79
  'عَبَسَ', // 80
  'ٱلتَّكْوِير', // 81
  'ٱلْإِنفِطَار', // 82
  'ٱلْمُطَفِّفِين', // 83
  'ٱلْإِنشِقَاق', // 84
  'ٱلْبُرُوج', // 85
  'ٱلطَّارِق', // 86
  'ٱلْأَعْلَىٰ', // 87
  'ٱلْغَاشِيَة', // 88
  'ٱلْفَجْر', // 89
  'ٱلْبَلَد', // 90
  'ٱلشَّمْس', // 91
  'ٱللَّيْل', // 92
  'ٱلضُّحَىٰ', // 93
  'ٱلشَّرْح', // 94
  'ٱلتِّين', // 95
  'ٱلْعَلَق', // 96
  'ٱلْقَدْر', // 97
  'ٱلْبَيِّنَة', // 98
  'ٱلزَّلْزَلَة', // 99
  'ٱلْعَادِيَات', // 100
  'ٱلْقَارِعَة', // 101
  'ٱلتَّكَاثُر', // 102
  'ٱلْعَصْر', // 103
  'ٱلْهُمَزَة', // 104
  'ٱلْفِيل', // 105
  'قُرَيْش', // 106
  'ٱلْمَاعُون', // 107
  'ٱلْكَوْثَر', // 108
  'ٱلْكَافِرُون', // 109
  'ٱلنَّصْر', // 110
  'ٱلْمَسَد', // 111
  'ٱلْإِخْلَاص', // 112
  'ٱلْفَلَق', // 113
  'ٱلنَّاس', // 114
];

/// Juz names in Arabic
const List<String> juzNames = [
  'ٱلْجُزْءُ ٱلْأَوَّلُ', // 1
  'ٱلْجُزْءُ ٱلثَّانِي', // 2
  'ٱلْجُزْءُ ٱلثَّالِثُ', // 3
  'ٱلْجُزْءُ ٱلرَّابِعُ', // 4
  'ٱلْجُزْءُ ٱلْخَامِسُ', // 5
  'ٱلْجُزْءُ ٱلسَّادِسُ', // 6
  'ٱلْجُزْءُ ٱلسَّابِعُ', // 7
  'ٱلْجُزْءُ ٱلثَّامِنُ', // 8
  'ٱلْجُزْءُ ٱلتَّاسِعُ', // 9
  'ٱلْجُزْءُ ٱلْعَاشِرُ', // 10
  'ٱلْجُزْءُ ٱلْحَادِي عَشَرَ', // 11
  'ٱلْجُزْءُ ٱلثَّانِي عَشَرَ', // 12
  'ٱلْجُزْءُ ٱلثَّالِثَ عَشَرَ', // 13
  'ٱلْجُزْءُ ٱلرَّابِعَ عَشَرَ', // 14
  'ٱلْجُزْءُ ٱلْخَامِسَ عَشَرَ', // 15
  'ٱلْجُزْءُ ٱلسَّادِسَ عَشَرَ', // 16
  'ٱلْجُزْءُ ٱلسَّابِعَ عَشَرَ', // 17
  'ٱلْجُزْءُ ٱلثَّامِنَ عَشَرَ', // 18
  'ٱلْجُزْءُ ٱلتَّاسِعَ عَشَرَ', // 19
  'ٱلْجُزْءُ ٱلْعِشْرُونَ', // 20
  'ٱلْجُزْءُ ٱلْحَادِي وَٱلْعِشْرُونَ', // 21
  'ٱلْجُزْءُ ٱلثَّانِي وَٱلْعِشْرُونَ', // 22
  'ٱلْجُزْءُ ٱلثَّالِثُ وَٱلْعِشْرُونَ', // 23
  'ٱلْجُزْءُ ٱلرَّابِعُ وَٱلْعِشْرُونَ', // 24
  'ٱلْجُزْءُ ٱلْخَامِسُ وَٱلْعِشْرُونَ', // 25
  'ٱلْجُزْءُ ٱلسَّادِسُ وَٱلْعِشْرُونَ', // 26
  'ٱلْجُزْءُ ٱلسَّابِعُ وَٱلْعِشْرُونَ', // 27
  'ٱلْجُزْءُ ٱلثَّامِنُ وَٱلْعِشْرُونَ', // 28
  'ٱلْجُزْءُ ٱلتَّاسِعُ وَٱلْعِشْرُونَ', // 29
  'ٱلْجُزْءُ ٱلثَّلَاثُونَ', // 30
];

/// Juz start positions defined by surah and ayah
/// Each entry is [surah, ayah] where the Juz begins
const List<List<int>> juzStartPositions = [
  [1, 1], // Juz 1
  [2, 142], // Juz 2
  [2, 253], // Juz 3
  [3, 93], // Juz 4
  [4, 24], // Juz 5
  [4, 148], // Juz 6
  [5, 82], // Juz 7
  [6, 111], // Juz 8
  [7, 88], // Juz 9
  [8, 41], // Juz 10
  [9, 93], // Juz 11
  [11, 6], // Juz 12
  [12, 53], // Juz 13
  [15, 1], // Juz 14
  [17, 1], // Juz 15
  [18, 75], // Juz 16
  [21, 1], // Juz 17
  [23, 1], // Juz 18
  [25, 21], // Juz 19
  [27, 56], // Juz 20
  [29, 46], // Juz 21
  [33, 31], // Juz 22
  [36, 28], // Juz 23
  [39, 32], // Juz 24
  [41, 47], // Juz 25
  [46, 1], // Juz 26
  [51, 31], // Juz 27
  [58, 1], // Juz 28
  [67, 1], // Juz 29
  [78, 1], // Juz 30
];

/// Get Juz number (1-30) for a given surah and ayah
int getJuzForPosition(int surah, int ayah) {
  for (int i = juzStartPositions.length - 1; i >= 0; i--) {
    final juzSurah = juzStartPositions[i][0];
    final juzAyah = juzStartPositions[i][1];
    // Check if current position is at or after this Juz start
    if (surah > juzSurah || (surah == juzSurah && ayah >= juzAyah)) {
      return i + 1;
    }
  }
  return 1;
}

/// Surah name info with transliteration and meaning
class SurahNameInfo {
  final String name;
  final String meaning;

  const SurahNameInfo(this.name, this.meaning);
}

/// Language-specific Surah names with transliterations
/// Each language map contains surah numbers (1-114) mapped to SurahNameInfo
const Map<String, Map<int, SurahNameInfo>> translatedSurahNames = {
  'en': {
    1: SurahNameInfo('Al-Fatihah', 'The Opening'),
    2: SurahNameInfo('Al-Baqarah', 'The Cow'),
    3: SurahNameInfo('Aali-Imran', 'The Family of Imran'),
    4: SurahNameInfo('An-Nisa', 'The Women'),
    5: SurahNameInfo('Al-Ma\'idah', 'The Table'),
    6: SurahNameInfo('Al-An\'am', 'The Cattle'),
    7: SurahNameInfo('Al-A\'raf', 'The Heights'),
    8: SurahNameInfo('Al-Anfal', 'The Spoils of War'),
    9: SurahNameInfo('At-Taubah', 'The Repentance'),
    10: SurahNameInfo('Yunus', 'Jonah'),
    11: SurahNameInfo('Hud', 'Hud'),
    12: SurahNameInfo('Yusuf', 'Joseph'),
    13: SurahNameInfo('Ar-Ra\'d', 'The Thunder'),
    14: SurahNameInfo('Ibrahim', 'Abraham'),
    15: SurahNameInfo('Al-Hijr', 'The Rocky Tract'),
    16: SurahNameInfo('An-Nahl', 'The Bees'),
    17: SurahNameInfo('Al-Isra\'', 'The Night Journey'),
    18: SurahNameInfo('Al-Kahf', 'The Cave'),
    19: SurahNameInfo('Maryam', 'Mary'),
    20: SurahNameInfo('Ta-Ha', 'Taa Haa'),
    21: SurahNameInfo('Al-Anbiya\'', 'The Prophets'),
    22: SurahNameInfo('Al-Haj', 'The Pilgrimage'),
    23: SurahNameInfo('Al-Mu\'minun', 'The Believers'),
    24: SurahNameInfo('An-Nur', 'The Light'),
    25: SurahNameInfo('Al-Furqan', 'The Criterion'),
    26: SurahNameInfo('Ash-Shu\'ara', 'The Poets'),
    27: SurahNameInfo('An-Naml', 'The Ants'),
    28: SurahNameInfo('Al-Qasas', 'The Stories'),
    29: SurahNameInfo('Al-Ankabut', 'The Spider'),
    30: SurahNameInfo('Ar-Rum', 'The Romans'),
    31: SurahNameInfo('Luqman', 'Luqman'),
    32: SurahNameInfo('As-Sajdah', 'The Prostration'),
    33: SurahNameInfo('Al-Ahzab', 'The Combined Forces'),
    34: SurahNameInfo('Saba\'', 'The Sabeans'),
    35: SurahNameInfo('Al-Fatir', 'The Originator'),
    36: SurahNameInfo('Ya-Sin', 'Yaseen'),
    37: SurahNameInfo('As-Saffah', 'Those Ranges in Ranks'),
    38: SurahNameInfo('Sad', 'The letter Saad'),
    39: SurahNameInfo('Az-Zumar', 'The Groups'),
    40: SurahNameInfo('Ghafir', 'The Forgiver'),
    41: SurahNameInfo('Fusilat', 'Explained in detail'),
    42: SurahNameInfo('Ash-Shura', 'The Consultation'),
    43: SurahNameInfo('Az-Zukhruf', 'The ornaments of gold'),
    44: SurahNameInfo('Ad-Dukhan', 'The Smoke'),
    45: SurahNameInfo('Al-Jathiyah', 'The Kneeling'),
    46: SurahNameInfo('Al-Ahqaf', 'The Valley'),
    47: SurahNameInfo('Muhammad', 'Muhammad'),
    48: SurahNameInfo('Al-Fat\'h', 'The Victory'),
    49: SurahNameInfo('Al-Hujurat', 'The Dwellings'),
    50: SurahNameInfo('Qaf', 'The letter Qaaf'),
    51: SurahNameInfo('Adz-Dzariyah', 'The Scatterers'),
    52: SurahNameInfo('At-Tur', 'The Mount'),
    53: SurahNameInfo('An-Najm', 'The Star'),
    54: SurahNameInfo('Al-Qamar', 'The Moon'),
    55: SurahNameInfo('Ar-Rahman', 'The Most Beneficent'),
    56: SurahNameInfo('Al-Waqi\'ah', 'The Event'),
    57: SurahNameInfo('Al-Hadid', 'The Iron'),
    58: SurahNameInfo('Al-Mujadilah', 'The Reasoning'),
    59: SurahNameInfo('Al-Hashr', 'The Gathering'),
    60: SurahNameInfo('Al-Mumtahanah', 'The woman who will be tested'),
    61: SurahNameInfo('As-Saf', 'The Ranks'),
    62: SurahNameInfo('Al-Jum\'ah', 'Friday'),
    63: SurahNameInfo('Al-Munafiqun', 'The Hypocrites'),
    64: SurahNameInfo('At-Taghabun', 'Mutual Loss and Gain'),
    65: SurahNameInfo('At-Talaq', 'The Divorce'),
    66: SurahNameInfo('At-Tahrim', 'The Prohibition'),
    67: SurahNameInfo('Al-Mulk', 'The Sovereignty'),
    68: SurahNameInfo('Al-Qalam', 'The Pen'),
    69: SurahNameInfo('Al-Haqqah', 'The Inevitable'),
    70: SurahNameInfo('Al-Ma\'arij', 'The Ascending Stairways'),
    71: SurahNameInfo('Nuh', 'Noah'),
    72: SurahNameInfo('Al-Jinn', 'The Jinn'),
    73: SurahNameInfo('Al-Muzammil', 'The Enshrouded One'),
    74: SurahNameInfo('Al-Mudaththir', 'The Cloaked One'),
    75: SurahNameInfo('Al-Qiyamah', 'The Resurrection'),
    76: SurahNameInfo('Al-Insan', 'The Man'),
    77: SurahNameInfo('Al-Mursalat', 'The Emissaries'),
    78: SurahNameInfo('An-Naba\'', 'The Announcement'),
    79: SurahNameInfo('An-Nazi\'at', 'Those Who Drag Forth'),
    80: SurahNameInfo('\'Abasa', 'He Frowned'),
    81: SurahNameInfo('At-Takwir', 'The Overthrowing'),
    82: SurahNameInfo('Al-Infitar', 'The Cleaving'),
    83: SurahNameInfo('Al-Mutaffifin', 'The Defrauders'),
    84: SurahNameInfo('Al-Inshiqaq', 'The Sundering'),
    85: SurahNameInfo('Al-Buruj', 'The Constellations'),
    86: SurahNameInfo('At-Tariq', 'The Nightcomer'),
    87: SurahNameInfo('Al-A\'la', 'The Most High'),
    88: SurahNameInfo('Al-Ghashiyah', 'The Overwhelming'),
    89: SurahNameInfo('Al-Fajr', 'The Dawn'),
    90: SurahNameInfo('Al-Balad', 'The City'),
    91: SurahNameInfo('Ash-Shams', 'The Sun'),
    92: SurahNameInfo('Al-Layl', 'The Night'),
    93: SurahNameInfo('Adh-Dhuha', 'The Morning Hours'),
    94: SurahNameInfo('Al-Inshirah', 'The Consolation'),
    95: SurahNameInfo('At-Tin', 'The Fig'),
    96: SurahNameInfo('Al-\'Alaq', 'The Clot'),
    97: SurahNameInfo('Al-Qadar', 'The Night of Decree'),
    98: SurahNameInfo('Al-Bayinah', 'The Clear Evidence'),
    99: SurahNameInfo('Az-Zalzalah', 'The Earthquake'),
    100: SurahNameInfo('Al-\'Adiyah', 'The Chargers'),
    101: SurahNameInfo('Al-Qari\'ah', 'The Calamity'),
    102: SurahNameInfo('At-Takathur', 'The Competition'),
    103: SurahNameInfo('Al-\'Asr', 'The Declining Day'),
    104: SurahNameInfo('Al-Humazah', 'The Traducer'),
    105: SurahNameInfo('Al-Fil', 'The Elephant'),
    106: SurahNameInfo('Quraish', 'Quraysh'),
    107: SurahNameInfo('Al-Ma\'un', 'Act of Kindess'),
    108: SurahNameInfo('Al-Kauthar', 'The Abundance'),
    109: SurahNameInfo('Al-Kafirun', 'The Disbelievers'),
    110: SurahNameInfo('An-Nasr', 'Divine Support'),
    111: SurahNameInfo('Al-Masad', 'The Palm Fiber'),
    112: SurahNameInfo('Al-Ikhlas', 'The Sincerity'),
    113: SurahNameInfo('Al-Falaq', 'The Daybreak'),
    114: SurahNameInfo('An-Nas', 'Mankind'),
  },
  'az': {
    1: SurahNameInfo('Fatihə', 'Kitabı açan'),
    2: SurahNameInfo('Bəqərə', 'İnək'),
    3: SurahNameInfo('Ali İmran', 'İmranın ailəsi'),
    4: SurahNameInfo('Nisə', 'Qadınlar'),
    5: SurahNameInfo('Maidə', 'Süfrə'),
    6: SurahNameInfo('Ənam', 'Mal-qara'),
    7: SurahNameInfo('Əraf', 'Sədd'),
    8: SurahNameInfo('Ənfal', 'Qənimətlər'),
    9: SurahNameInfo('Tövbə', 'Tövbə'),
    10: SurahNameInfo('Yunus', 'Yunus'),
    11: SurahNameInfo('Hud', 'Hud'),
    12: SurahNameInfo('Yusuf', 'Yusuf'),
    13: SurahNameInfo('Rad', 'Göy gurultusu'),
    14: SurahNameInfo('İbrahim', 'İbrahim'),
    15: SurahNameInfo('Hicr', 'Hicr'),
    16: SurahNameInfo('Nəhl', 'Bal arısı'),
    17: SurahNameInfo('İsra', 'Gecə səyahəti'),
    18: SurahNameInfo('Kəhf', 'Mağara'),
    19: SurahNameInfo('Məryəm', 'Məryəm'),
    20: SurahNameInfo('Ta ha', 'Ta ha'),
    21: SurahNameInfo('Ənbiya', 'Peyğəmbərlər'),
    22: SurahNameInfo('Həcc', 'Həcc'),
    23: SurahNameInfo('Muminun', 'Möminlər'),
    24: SurahNameInfo('Nur', 'Nur'),
    25: SurahNameInfo('Furqan', 'Haqqı batildən ayıran'),
    26: SurahNameInfo('Şuəra', 'Şairlər'),
    27: SurahNameInfo('Nəml', 'Qarışqalar'),
    28: SurahNameInfo('Qasas', 'Əhvalat'),
    29: SurahNameInfo('Ənkəbut', 'Hörümçək'),
    30: SurahNameInfo('Rum', 'Rumlular'),
    31: SurahNameInfo('Loğman', 'Loğman'),
    32: SurahNameInfo('Səcdə', 'Səcdə'),
    33: SurahNameInfo('Əhzab', 'Müttəfiqlər'),
    34: SurahNameInfo('Səba', 'Səba'),
    35: SurahNameInfo('Fatir', 'Yaradan'),
    36: SurahNameInfo('Ya sin', 'Ya sin'),
    37: SurahNameInfo('Saffat', 'Səf-səf duranlar'),
    38: SurahNameInfo('Sad', 'Sad'),
    39: SurahNameInfo('Zumər', 'Zümrələr'),
    40: SurahNameInfo('Ğafir', 'Bağışlayan'),
    41: SurahNameInfo('Fussilət', 'Müfəssəl izah edilmiş'),
    42: SurahNameInfo('Şura', 'Şura'),
    43: SurahNameInfo('Zuxruf', 'Zinət'),
    44: SurahNameInfo('Duxan', 'Tüstü'),
    45: SurahNameInfo('Casiyə', 'Diz çökənlər'),
    46: SurahNameInfo('Əhqaf', 'Qumsal təpələr'),
    47: SurahNameInfo('Muhəmməd', 'Muhəmməd'),
    48: SurahNameInfo('Fəth', 'Zəfər'),
    49: SurahNameInfo('Hucurat', 'Otaqlar'),
    50: SurahNameInfo('Qaf', 'Qaf'),
    51: SurahNameInfo('Zəriyət', 'Toz-torpağı səpələyənlər'),
    52: SurahNameInfo('Tur', 'Dağ'),
    53: SurahNameInfo('Nəcm', 'Ulduz'),
    54: SurahNameInfo('Qamər', 'Ay'),
    55: SurahNameInfo('Rahmən', 'Mərhəmətli'),
    56: SurahNameInfo('Vaqiə', 'Vaqiə'),
    57: SurahNameInfo('Hədid', 'Dəmir'),
    58: SurahNameInfo('Mucadilə', 'Mübahisə edən qadın'),
    59: SurahNameInfo('Həşr', 'Toplanma'),
    60: SurahNameInfo('Mumtəhənə', 'İmtahana çəkilən qadın'),
    61: SurahNameInfo('Saff', 'Səf'),
    62: SurahNameInfo('Cumuə', 'Cümə'),
    63: SurahNameInfo('Munafiqun', 'Münafiqlər'),
    64: SurahNameInfo('Təğabun', 'Qarşılıqlı aldanma'),
    65: SurahNameInfo('Talaq', 'Boşanma'),
    66: SurahNameInfo('Təhrim', 'Qadağan'),
    67: SurahNameInfo('Mulk', 'Mülk'),
    68: SurahNameInfo('Qələm', 'Qələm'),
    69: SurahNameInfo('Haqqə', 'Haqq olan'),
    70: SurahNameInfo('Məaric', 'Dərəcələr'),
    71: SurahNameInfo('Nuh', 'Nuh'),
    72: SurahNameInfo('Cinn', 'Cinlər'),
    73: SurahNameInfo('Muzzəmmil', 'Bürünmüş'),
    74: SurahNameInfo('Muddəssir', 'Örtünmüş'),
    75: SurahNameInfo('Qiyamə', 'Qiyamət'),
    76: SurahNameInfo('İnsan', 'İnsan'),
    77: SurahNameInfo('Mursəlat', 'Göndərilənlər'),
    78: SurahNameInfo('Nəbə', 'Xəbər'),
    79: SurahNameInfo('Naziat', 'Can alanlar'),
    80: SurahNameInfo('Əbəsə', 'Qaşqabağını tökdü'),
    81: SurahNameInfo('Təkvir', 'Sarınma'),
    82: SurahNameInfo('İnfitar', 'Parçalanma'),
    83: SurahNameInfo('Mutaffifin', 'Çəkidə və ölçüdə aldadanlar'),
    84: SurahNameInfo('İnşiqaq', 'Yarılma'),
    85: SurahNameInfo('Buruc', 'Bürclər'),
    86: SurahNameInfo('Tariq', 'Gecə yolçusu'),
    87: SurahNameInfo('A\'lə', 'Ən uca'),
    88: SurahNameInfo('Ğaşiyə', 'Bürüyən'),
    89: SurahNameInfo('Fəcr', 'Dan yeri'),
    90: SurahNameInfo('Bələd', 'Şəhər'),
    91: SurahNameInfo('Şəms', 'Günəş'),
    92: SurahNameInfo('Leyl', 'Gecə'),
    93: SurahNameInfo('Duha', 'Səhər'),
    94: SurahNameInfo('Şərh', 'Açma'),
    95: SurahNameInfo('Tin', 'Əncir'),
    96: SurahNameInfo('Ələq', 'Laxtalanmış qan'),
    97: SurahNameInfo('Qədr', 'Qədr gecəsi'),
    98: SurahNameInfo('Beyyinə', 'Açıq-aydın dəlil'),
    99: SurahNameInfo('Zəlzələ', 'Zəlzələ'),
    100: SurahNameInfo('Adiyat', 'Çapanlar'),
    101: SurahNameInfo('Qariə', 'Qorxuya salan'),
    102: SurahNameInfo('Təkasur', 'Çoxluğa hərislik'),
    103: SurahNameInfo('Əsr', 'Axşam çağı'),
    104: SurahNameInfo('Huməzə', 'Tənə edən'),
    105: SurahNameInfo('Fil', 'Fil'),
    106: SurahNameInfo('Qureyş', 'Qureyş'),
    107: SurahNameInfo('Maun', 'Xırda xuruş'),
    108: SurahNameInfo('Kovsər', 'Bolluq'),
    109: SurahNameInfo('Kafirun', 'Kafirlər'),
    110: SurahNameInfo('Nəsr', 'Kömək'),
    111: SurahNameInfo('Məsəd', 'Xurma lifi'),
    112: SurahNameInfo('İxlas', 'Səmimi etiqad'),
    113: SurahNameInfo('Fələq', 'Sübh'),
    114: SurahNameInfo('Nəs', 'İnsanlar'),
  },
};

/// Get translated Surah name for a specific language
/// Falls back to English if language is not available
/// Returns just the name (not the meaning)
String getTranslatedSurahName(int surahNumber, String languageCode) {
  // Validate surah number
  if (surahNumber < 1 || surahNumber > 114) {
    return 'Surah $surahNumber';
  }

  // Try to get name in requested language
  final languageMap = translatedSurahNames[languageCode];
  if (languageMap != null) {
    final info = languageMap[surahNumber];
    if (info != null) {
      return info.name;
    }
  }

  // Fallback to English
  final englishMap = translatedSurahNames['en'];
  if (englishMap != null) {
    final info = englishMap[surahNumber];
    if (info != null) {
      return info.name;
    }
  }

  // Final fallback
  return 'Surah $surahNumber';
}

/// UI localizations for cover page, TOC, etc.
const Map<String, Map<String, String>> uiLocalizations = {
  'en': {
    'noble_quran': 'The Noble Quran',
    'tajweed_coding': 'With Tajweed Color Coding',
    'translation': 'Translation',
    'word_by_word': 'Word-by-Word',
    'toc_title': 'Table of Contents',
    'toc_surah_prefix': 'Surah',
    'blank_page_text': 'This page is intentionally left blank',
    'rule_lafzatullah': 'LAFZATULLAH',
    'rule_izhar': 'Izhar',
    'rule_ikhfaa': 'Ikhfaa',
    'rule_idgham_ghunna': 'Idgham + Ghunna',
    'rule_idgham': 'Idgham',
    'rule_iqlab': 'Iqlab',
    'rule_qalqala': 'Qalqala',
    'rule_ghunna': 'Ghunna',
    'rule_madd': 'Madd',
  },
  'az': {
    'noble_quran': 'Qurani-Kərim',
    'tajweed_coding': 'Təcvid rəngləri ilə',
    'translation': 'Tərcümə',
    'word_by_word': 'Sözbəsöz',
    'toc_title': 'Səhifələr üzrə Surələr',
    'toc_surah_prefix': 'Surə',
    'blank_page_text': 'Bu səhifə qəsdən boş buraxılmışdır',
    'rule_lafzatullah': 'Allah ləfzi',
    'rule_izhar': 'İzhar',
    'rule_ikhfaa': 'İxfə',
    'rule_idgham_ghunna': 'İdğam (ğunnəli)',
    'rule_idgham': 'İdğam',
    'rule_iqlab': 'İqlab',
    'rule_qalqala': 'Qalqalə',
    'rule_ghunna': 'Ğunnə',
    'rule_madd': 'Mədd',
  },
};

/// Get localized UI text for a specific language
/// Falls back to English if language is not available
String getLocalizedText(String key, String languageCode) {
  final lang = uiLocalizations.containsKey(languageCode) ? languageCode : 'en';
  return uiLocalizations[lang]![key] ?? uiLocalizations['en']![key] ?? key;
}
