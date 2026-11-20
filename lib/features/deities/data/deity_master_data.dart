// Master dataset for Vishnu, Murugan and Vinayagar deities
// Contains canonical Names/Titles, Avatars (Dashavatara), Forms, and Associated Deities/Consorts.

class DeityNameItem {
  final String nameEn;
  final String nameTa;
  final String? description;

  const DeityNameItem({
    required this.nameEn,
    required this.nameTa,
    this.description,
  });

  String get displayName => '$nameTa – $nameEn';
}

class DeityFormItem {
  final int id;
  final String nameEn;
  final String nameTa;
  final String type; // e.g. 'Dashavatara', 'Temple Form', 'Traditional 32 Forms', 'Special Form'
  final String description;
  final String image;

  const DeityFormItem({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.type,
    required this.description,
    this.image = '',
  });

  String get displayName => '$nameTa – $nameEn';
}

/// ==========================================
/// 1. VISHNU MASTER DATA
/// ==========================================
class VishnuMasterData {
  static const String categoryName = 'விஷ்ணு';
  static const String categoryNameEn = 'Vishnu';
  static const String defaultGender = 'ஆண் தெய்வம் (Male Deity)';
  static const String defaultRelationship = 'காக்கும் கடவுள் (Supreme Protector)';

  // 18 Canonical Names / Titles
  static const List<DeityNameItem> namesAndTitles = [
    DeityNameItem(nameEn: 'Vishnu', nameTa: 'விஷ்ணு', description: 'எங்கும் நிறைந்த சர்வ வியாபி'),
    DeityNameItem(nameEn: 'Narayana', nameTa: 'நாராயணன்', description: 'நீரில் துயில்கொள்பவன் / உயிர்களின் புகலிடம்'),
    DeityNameItem(nameEn: 'Hari', nameTa: 'ஹரி', description: 'பாவங்களையும் துன்பங்களையும் போக்குபவன்'),
    DeityNameItem(nameEn: 'Vasudeva', nameTa: 'வாசுதேவன்', description: 'அண்டசராசரங்களில் வசிப்பவன் / வசுதேவர் மைந்தன்'),
    DeityNameItem(nameEn: 'Madhava', nameTa: 'மாதவன்', description: 'மகாலட்சுமியின் மணாளன் / ஞானத்தின் இருப்பிடம்'),
    DeityNameItem(nameEn: 'Govinda', nameTa: 'கோவிந்தன்', description: 'பசுக்களையும் பூமிதேவியையும் காப்பவன்'),
    DeityNameItem(nameEn: 'Damodara', nameTa: 'தாமோதரன்', description: 'வயிற்றில் கயிற்றால் கட்டப்பட்ட யசோதையின் பாலன்'),
    DeityNameItem(nameEn: 'Achyuta', nameTa: 'அச்சுதன்', description: 'என்றும் நிலைத்திருப்பவன் / நழுவாதவன்'),
    DeityNameItem(nameEn: 'Ananta', nameTa: 'அனந்தன்', description: 'முடிவில்லாத எல்லையற்ற பரம்பொருள்'),
    DeityNameItem(nameEn: 'Padmanabha', nameTa: 'பத்மநாபன்', description: 'தொப்புள் கொடித் தாமரையில் பிரம்மனைப் படைத்தவன்'),
    DeityNameItem(nameEn: 'Hrishikesha', nameTa: 'ஹ்ருஷீகேசன்', description: 'புலன்களை அடக்கி ஆள்பவன்'),
    DeityNameItem(nameEn: 'Janardhana', nameTa: 'ஜனார்த்தனன்', description: 'மக்களின் பிறவித்துன்பங்களைப் போக்குபவன்'),
    DeityNameItem(nameEn: 'Trivikrama', nameTa: 'திரிவிக்ரமன்', description: 'மூன்று உலகங்களையும் ஓரடியால் அளந்த உலகளந்த பெருமாள்'),
    DeityNameItem(nameEn: 'Upendra', nameTa: 'உபேந்திரன்', description: 'இந்திரனுக்கு இளவNonUserலாய்த் தோன்றி உதவியவன்'),
    DeityNameItem(nameEn: 'Purushottama', nameTa: 'புருஷோத்தமன்', description: 'புருஷர்களில் உத்தமமான முழுமுதற்கடவுள்'),
    DeityNameItem(nameEn: 'Sridhara', nameTa: 'ஸ்ரீதரன்', description: 'மார்பில் ஸ்ரீதேவியைத் தாங்கியவன்'),
    DeityNameItem(nameEn: 'Keshava', nameTa: 'கேசவன்', description: 'அழகிய கேசமுடையவன் / கேசி அசுரனை வதைத்தவன்'),
    DeityNameItem(nameEn: 'Lakshminarayana', nameTa: 'லட்சுமி நாராயணன்', description: 'மகாலட்சுமியுடன் இணைந்த மங்கள வடிவம்'),
  ];

  // Dashavatara (10 Avatars)
  static const List<DeityFormItem> dashavatara = [
    DeityFormItem(
      id: 1,
      nameEn: 'Matsya',
      nameTa: 'மச்ச அவதாரம்',
      type: 'Dashavatara',
      description: 'பிரளய காலத்தில் வேதங்களையும் சத்யவிரத மன்னனையும் காக்க மீன் வடிவில் தோன்றிய முதல் அவதாரம்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 2,
      nameEn: 'Kurma',
      nameTa: 'கூர்ம அவதாரம்',
      type: 'Dashavatara',
      description: 'பாற்கடல் கடையும்போது மந்திர மலையைத் தாங்கி நின்ற ஆமை வடிவம்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 3,
      nameEn: 'Varaha',
      nameTa: 'வராக அவதாரம்',
      type: 'Dashavatara',
      description: 'இரணியாட்சனை வதம் செய்து கடலுள் மூழ்கிய பூமிதேவியை தன் கோரைப் பல்லில் மீட்டுக் காத்த வெள்ளை பன்றி வடிவம்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 4,
      nameEn: 'Narasimha',
      nameTa: 'நரசிம்ம அவதாரம்',
      type: 'Dashavatara',
      description: 'பிரகலாதனின் பக்தியைக் காக்க தூணிலிருந்து பிளந்து தோன்றி இரணியகசிபுவை வதம் செய்த மனித-சிங்க அவதாரம்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 5,
      nameEn: 'Vamana',
      nameTa: 'வாமன அவதாரம்',
      type: 'Dashavatara',
      description: 'மகாபலி சக்கரவர்த்தியின் கர்வத்தை அடக்கி மூன்றடி நிலம் கேட்டு வானையும் பூமியையும் அளந்த குள்ள பிரம்மச்சாரி வடிவம்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 6,
      nameEn: 'Parashurama',
      nameTa: 'பரசுராம அவதாரம்',
      type: 'Dashavatara',
      description: 'தர்மம் தவறிய கொடுங்கோல் அரசர்களை அடக்கி தர்மத்தை நிலைநாட்டிய கோடரி ஏந்திய ஜமதக்னி முனிவர் மைந்தன்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 7,
      nameEn: 'Rama',
      nameTa: 'ராம அவதாரம்',
      type: 'Dashavatara',
      description: 'ஏகபத்தினி விரதமும் தர்ம நெறியும் தவறாத அயோத்தி தசரத சக்ரவர்த்தி திருமகன்; ராவண சம்ஹார மூர்த்தி.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 8,
      nameEn: 'Krishna',
      nameTa: 'கிருஷ்ண அவதாரம்',
      type: 'Dashavatara',
      description: 'பகவத்கீதையை உலகிற்கு அருளி அதர்மத்தை அழித்து பக்தர்களைக் காத்த யதுகுல திலகன்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 9,
      nameEn: 'Buddha',
      nameTa: 'புத்த அவதாரம்',
      type: 'Dashavatara',
      description: 'அஹிம்சை, கருணை, ஜீவகாருண்ய நெறிகளை உலகிற்கு உபதேசித்த அமைதி வடிவம் (சில மரபுகளில் பலராமர் சேர்க்கப்படுவர்).',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormItem(
      id: 10,
      nameEn: 'Kalki',
      nameTa: 'கல்கி அவதாரம்',
      type: 'Dashavatara',
      description: 'கலியுகத்தின் இறுதியில் அதர்மங்களை முற்றிலும் அழித்து சத்திய யுகத்தைத் தொடங்கி வைக்க வரவிருக்கும் வெள்ளைக் குதிரை வீரன்.',
      image: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
  ];

  // Additional Vishnu Forms (Temple / Manifestation Forms)
  static const List<DeityFormItem> additionalForms = [
    DeityFormItem(
      id: 11,
      nameEn: 'Ananta Padmanabha',
      nameTa: 'அனந்த பத்மநாபன்',
      type: 'Temple Form',
      description: 'ஆதிசேஷன் மீது பள்ளி கொண்ட அனந்தசயன திருக்கோலம் (திருவனந்தபுரம்).',
    ),
    DeityFormItem(
      id: 12,
      nameEn: 'Lakshmi Narayana',
      nameTa: 'லட்சுமி நாராயணன்',
      type: 'Temple Form',
      description: 'மகாலட்சுமி தேவியை மடியில் அமர்த்தி அருளும் ஆனந்த மங்கள வடிவம்.',
    ),
    DeityFormItem(
      id: 13,
      nameEn: 'Yoga Narasimha',
      nameTa: 'யோக நரசிம்மர்',
      type: 'Temple Form',
      description: 'யோக பட்டையுடன் பத்மாசனத்தில் சாந்த தியானத்தில் வீற்றிருக்கும் நரசிம்ம வடிவம்.',
    ),
    DeityFormItem(
      id: 14,
      nameEn: 'Ugra Narasimha',
      nameTa: 'உக்கிர நரசிம்மர்',
      type: 'Temple Form',
      description: 'இரணியனை தன் மடியில் கிடத்தி வதம் செய்யும் உக்கிர வீரத் திருக்கோலம்.',
    ),
    DeityFormItem(
      id: 15,
      nameEn: 'Shanta Narasimha',
      nameTa: 'சாந்த நரசிம்மர்',
      type: 'Temple Form',
      description: 'பிரகலாதனின் வேண்டுதலால் உக்கிரம் தணிந்து புன்னகையுடன் அருள்பாலிக்கும் சாந்த வடிவம்.',
    ),
    DeityFormItem(
      id: 16,
      nameEn: 'Hayagriva',
      nameTa: 'ஹயக்ரீவர்',
      type: 'Temple Form',
      description: 'குதிரை முகத்துடன் கூடிய கல்வி மற்றும் கலைகளின் ஞான தெய்வ வடிவம்.',
    ),
    DeityFormItem(
      id: 17,
      nameEn: 'Dhanvantari',
      nameTa: 'தன்வந்திரி',
      type: 'Temple Form',
      description: 'பாற்கடலிலிருந்து அமிர்த கலசத்துடன் தோன்றிய ஆயுர்வேத மருத்துவ தெய்வம்.',
    ),
    DeityFormItem(
      id: 18,
      nameEn: 'Jagannatha',
      nameTa: 'ஜகந்நாதர்',
      type: 'Temple Form',
      description: 'பூரி திருத்தலத்தில் பலராமர் மற்றும் சுபத்திரையுடன் எழுந்தருளிய உலகநாதர்.',
    ),
    DeityFormItem(
      id: 19,
      nameEn: 'Ranganatha',
      nameTa: 'ரங்கநாதர்',
      type: 'Temple Form',
      description: 'ஸ்ரீரங்கத்தில் காவிரி நதிக்கரையில் ஆதிசேஷ சயனத்தில் பள்ளி கொண்ட பெரிய பெருமாள்.',
    ),
    DeityFormItem(
      id: 20,
      nameEn: 'Venkateswara',
      nameTa: 'வெங்கடேஸ்வரர்',
      type: 'Temple Form',
      description: 'திருப்பதி ஏழுகிரி வாசலில் நின்ற திருக்கோலத்தில் கலியுக வரதனாக அருளும் ஸ்ரீனிவாசன்.',
    ),
    DeityFormItem(
      id: 21,
      nameEn: 'Badri Narayana',
      nameTa: 'பத்ரி நாராயணன்',
      type: 'Temple Form',
      description: 'இமயமலை பத்ரிநாத்தில் பத்மாசனத்தில் தியான யோகத்தில் வீற்றிருக்கும் விஷ்ணு வடிவம்.',
    ),
  ];

  // Associated Consort Deities
  static const List<String> associatedConsorts = [
    'மகாலட்சுமி (Mahalakshmi)',
    'ஸ்ரீதேவி (Sridevi)',
    'பூதேவி (Bhudevi)',
    'ஸ்ரீதேவி & பூதேவி (Sridevi & Bhudevi)',
    'பத்மாவதி தாயார் (Padmavati Thayar)',
    'ஆண்டாள் (Andal)',
  ];
}

/// ==========================================
/// 2. MURUGAN MASTER DATA
/// ==========================================
class MuruganMasterData {
  static const String categoryName = 'முருகன்';
  static const String categoryNameEn = 'Murugan';
  static const String defaultGender = 'ஆண் தெய்வம் (Male Deity)';
  static const String defaultParentDeity = 'சிவபெருமான் & பார்வதி தேவி (Lord Shiva & Parvati)';
  static const String defaultRelationship = 'தந்தை & தாய் (Parents)';

  // 13 Canonical Names / Titles
  static const List<DeityNameItem> namesAndTitles = [
    DeityNameItem(nameEn: 'Murugan', nameTa: 'முருகன்', description: 'முருகு என்றால் அழகு, இளமை, தெய்வீகம் கொண்டவன்'),
    DeityNameItem(nameEn: 'Subrahmanya', nameTa: 'சுப்பிரமணியர்', description: 'மேலான பிரம்ம ஞானம் உடையவன்'),
    DeityNameItem(nameEn: 'Kartikeya', nameTa: 'கார்த்திகேயன்', description: 'கார்த்திகைப் பெண்களால் பாலூட்டி வளர்க்கப்பட்டவன்'),
    DeityNameItem(nameEn: 'Skanda', nameTa: 'ஸ்கந்தன்', description: 'சிவபெருமானின் நெற்றிக்கண் தீப்பொறியிலிருந்து உதித்தவன்'),
    DeityNameItem(nameEn: 'Shanmukha', nameTa: 'சண்முகர்', description: 'ஆறுமுகங்கள் கொண்டு அனைத்து திசைகளிலும் அருள்பவன்'),
    DeityNameItem(nameEn: 'Arumugam', nameTa: 'ஆறுமுகம்', description: 'ஆறு முகங்களும் பன்னிரு கரங்களும் கொண்ட வடிவம்'),
    DeityNameItem(nameEn: 'Saravanabhava', nameTa: 'சரவணபவன்', description: 'சரவணப் பொய்கையில் மலர்ந்த ஞானக் குழந்தை'),
    DeityNameItem(nameEn: 'Kumara', nameTa: 'குமரன்', description: 'என்றும் மாறாத இளமையுடன் திகழும் குமரக் கடவுள்'),
    DeityNameItem(nameEn: 'Guha', nameTa: 'குகன்', description: 'அடியார்களின் இதய குகையில் உறைபவன்'),
    DeityNameItem(nameEn: 'Senthil', nameTa: 'செந்தில்', description: 'செந்தில்நாதன் / திருச்செந்தூர் அதிபதி'),
    DeityNameItem(nameEn: 'Velayudhan', nameTa: 'வேலாயுதன்', description: 'அன்னை சக்தி அளித்த ஞானவேலை ஏந்தியவன்'),
    DeityNameItem(nameEn: 'Devasenapati', nameTa: 'தேவசேனாபதி', description: 'தேவ சேனைகளின் ஒப்பற்ற படைத்தலைவன்'),
    DeityNameItem(nameEn: 'Swaminatha', nameTa: 'சுவாமிநாதன்', description: 'தன் தந்தை சிவபெருமானுக்கே பிரணவ மந்திரம் உபதேசித்தவன்'),
  ];

  // Temple / Manifestation Forms (9)
  static const List<DeityFormItem> templeForms = [
    DeityFormItem(
      id: 1,
      nameEn: 'Dandayudhapani',
      nameTa: 'தண்டாயுதபாணி',
      type: 'Temple Form',
      description: 'பழனி மலையில் ஞானப் பழத்திற்காக ஆண்டிக் கோலத்தில் தண்டாயுதம் ஏந்தி நின்ற தவக் கோலம்.',
    ),
    DeityFormItem(
      id: 2,
      nameEn: 'Palaniandavar',
      nameTa: 'பழனியாண்டவர்',
      type: 'Temple Form',
      description: 'சகல பற்றுக்களையும் துறந்து ஆண்டிக் கோலத்தில் காட்சி தரும் பழனி ஞான வடிவம்.',
    ),
    DeityFormItem(
      id: 3,
      nameEn: 'Swaminathaswamy',
      nameTa: 'சுவாமிநாதசுவாமி',
      type: 'Temple Form',
      description: 'சுவாமிமலையில் தந்தை சிவனுக்கு குருவாக அமர்ந்து ஓங்காரப் பொருள் உரைத்த தகப்பன்சாமி திருக்கோலம்.',
    ),
    DeityFormItem(
      id: 4,
      nameEn: 'Shanmukha',
      nameTa: 'சண்முகர்',
      type: 'Temple Form',
      description: 'ஆறு திருமுகங்களும் பன்னிரண்டு திருக்கரங்களும் மயிலாசனமும் கொண்ட திவ்ய தரிசனம்.',
    ),
    DeityFormItem(
      id: 5,
      nameEn: 'Subrahmanya',
      nameTa: 'சுப்பிரமணியர்',
      type: 'Temple Form',
      description: 'திருப்பரங்குன்றத்தில் தெய்வானையை மணம் புரிந்து அருள்பாலிக்கும் மங்கள வடிவம்.',
    ),
    DeityFormItem(
      id: 6,
      nameEn: 'Balasubrahmanya',
      nameTa: 'பாலசுப்பிரமணியர்',
      type: 'Temple Form',
      description: 'இளங்குழந்தை வடிவில் கையில் வேலுடன் அருள் புரியும் பாலமுருகன் திருக்கோலம்.',
    ),
    DeityFormItem(
      id: 7,
      nameEn: 'Kartikeya',
      nameTa: 'கார்த்திகேயன்',
      type: 'Temple Form',
      description: 'சரவணப் பொய்கையில் கார்த்திகைப் பெண்களால் சீராட்டப்பட்ட கார்த்திகேய மூர்த்தி.',
    ),
    DeityFormItem(
      id: 8,
      nameEn: 'Velayudhaswamy',
      nameTa: 'வேலாயுதசுவாமி',
      type: 'Temple Form',
      description: 'சுடர்விடும் ஞானவேலைத் தாங்கி பக்தர்களின் வினை தீர்க்கும் கம்பீர வடிவம்.',
    ),
    DeityFormItem(
      id: 9,
      nameEn: 'Arumuga Perumal',
      nameTa: 'ஆறுமுகப் பெருமாள்',
      type: 'Temple Form',
      description: 'திருச்செந்தூரில் சூரபத்மனை வதம் செய்து அசுர சக்திகளை மயில், சேவலாக மாற்றிய சம்ஹார மூர்த்தி.',
    ),
  ];

  // Associated Consort Deities (Stored separately from forms!)
  static const List<String> associatedConsorts = [
    'வள்ளி (Valli)',
    'தெய்வானை (Deivanai / Devasena)',
    'வள்ளி & தெய்வானை (Valli & Deivanai)',
  ];
}

/// ==========================================
/// 3. VINAYAGAR MASTER DATA
/// ==========================================
class VinayagarMasterData {
  static const String categoryName = 'விநாயகர்';
  static const String categoryNameEn = 'Vinayagar';
  static const String defaultGender = 'ஆண் தெய்வம் (Male Deity)';
  static const String defaultParentDeity = 'சிவபெருமான் & பார்வதி தேவி (Lord Shiva & Parvati)';
  static const String defaultRelationship = 'தந்தை & தாய் (Parents)';

  // 10 Canonical Names / Titles
  static const List<DeityNameItem> namesAndTitles = [
    DeityNameItem(nameEn: 'Vinayagar', nameTa: 'விநாயகர்', description: 'தனக்கு மேல் தலைவன் இல்லாத ஒப்பற்ற முழுமுதற் கடவுள்'),
    DeityNameItem(nameEn: 'Ganesha', nameTa: 'கணேசர்', description: 'சிவ கணங்களின் தலைமை அதிபதி'),
    DeityNameItem(nameEn: 'Ganapati', nameTa: 'கணபதி', description: 'சகல பூத கணங்களுக்கும் தலைவர்'),
    DeityNameItem(nameEn: 'Pillaiyar', nameTa: 'பிள்ளையார்', description: 'பார்வதி-பரமேஸ்வரனின் செல்லப் பிள்ளை'),
    DeityNameItem(nameEn: 'Vighneshwara', nameTa: 'விக்னேஸ்வரர்', description: 'சகல தடைகளையும் விக்கினங்களையும் தகர்ப்பவர்'),
    DeityNameItem(nameEn: 'Gajanana', nameTa: 'கஜானனன்', description: 'யானை முகம் கொண்ட மங்கள மூர்த்தி'),
    DeityNameItem(nameEn: 'Ekadanta', nameTa: 'ஏகதந்தன்', description: 'ஒற்றைத் தந்தம் கொண்டவர் / பாரதம் எழுதியவர்'),
    DeityNameItem(nameEn: 'Lambodara', nameTa: 'லம்போதரன்', description: 'அகண்ட அண்ட சராசரங்களையும் தன்னுள் அடக்கிய பெருவயிறுடையவர்'),
    DeityNameItem(nameEn: 'Heramba', nameTa: 'ஹேரம்பர்', description: 'ஐந்து திருமுகங்களும் பத்து கரங்களும் கொண்ட கம்பீர மூர்த்தி'),
    DeityNameItem(nameEn: 'Ganesh', nameTa: 'கணேஷ்', description: 'அனைத்து நற்காரியங்களின் தொடக்க நாயகன்'),
  ];

  // Traditional 32 Forms of Ganesha (முப்பத்திரண்டு கணபதி திருமேனிகள்)
  static const List<DeityFormItem> traditional32Forms = [
    DeityFormItem(id: 1, nameEn: 'Bala Ganapati', nameTa: 'பால கணபதி', type: 'Traditional 32 Forms', description: 'குழந்தை வடிவில் கரும்பு, மாம்பழம், பலா, வாழைப்பழம் ஏந்தி அருளும் வடிவம்.'),
    DeityFormItem(id: 2, nameEn: 'Taruna Ganapati', nameTa: 'தருண கணபதி', type: 'Traditional 32 Forms', description: 'இளமைப் பொலிவுடன் எட்டு கரங்களில் பாசம், அங்குசம், நெற்கதிர் ஏந்திய வடிவம்.'),
    DeityFormItem(id: 3, nameEn: 'Bhakta Ganapati', nameTa: 'பக்த கணபதி', type: 'Traditional 32 Forms', description: 'பக்தர்களுக்கு எளிதில் அருளும் வெண்ணிற தேகமும் பழங்களும் ஏந்திய சாந்த வடிவம்.'),
    DeityFormItem(id: 4, nameEn: 'Veera Ganapati', nameTa: 'வீர கணபதி', type: 'Traditional 32 Forms', description: 'பதினாறு திருக்கரங்களில் ஆயுதங்கள் ஏந்திய போர்க்கள வீர வடிவம்.'),
    DeityFormItem(id: 5, nameEn: 'Shakti Ganapati', nameTa: 'சக்தி கணபதி', type: 'Traditional 32 Forms', description: 'சக்தி தேவியை மடியில் அமர்த்தி இல்லற நிம்மதி தரும் மங்கள வடிவம்.'),
    DeityFormItem(id: 6, nameEn: 'Dvija Ganapati', nameTa: 'துவிஜ கணபதி', type: 'Traditional 32 Forms', description: 'இருமுறை பிறந்த பிரம்மச்சாரி வடிவில் கமண்டலம், ஓலைச்சுவடி, தண்டம் ஏந்தியவர்.'),
    DeityFormItem(id: 7, nameEn: 'Siddhi Ganapati', nameTa: 'சித்தி கணபதி', type: 'Traditional 32 Forms', description: 'அஷ்டமா சித்திகளையும் அடியார்களுக்கு வழங்கி காரிய சித்தி அருளும் வடிவம்.'),
    DeityFormItem(id: 8, nameEn: 'Uchchhishta Ganapati', nameTa: 'உச்சிஷ்ட கணபதி', type: 'Traditional 32 Forms', description: 'நீல நிற மேனியுடன் சக்தி சமேதராக தாந்திரீக யோக சித்தி தரும் வடிவம்.'),
    DeityFormItem(id: 9, nameEn: 'Vighna Ganapati', nameTa: 'விக்ன கணபதி', type: 'Traditional 32 Forms', description: 'தடைகளை நீக்கி பொன் போன்ற பிரகாசத்துடன் சங்கு சக்கரமேந்திய வடிவம்.'),
    DeityFormItem(id: 10, nameEn: 'Kshipra Ganapati', nameTa: 'க்ஷிப்ர கணபதி', type: 'Traditional 32 Forms', description: 'வேண்டிய வரங்களை உடனுக்குடன் விரைவாக அருளும் கற்பக விருட்ச வடிவம்.'),
    DeityFormItem(id: 11, nameEn: 'Heramba Ganapati', nameTa: 'ஹேரம்ப கணபதி', type: 'Traditional 32 Forms', description: 'ஐந்து முகங்களுடன் சிம்ம வாகனத்தில் அமர்ந்து அச்சத்தைப் போக்கும் வடிவம்.'),
    DeityFormItem(id: 12, nameEn: 'Lakshmi Ganapati', nameTa: 'லட்சுமி கணபதி', type: 'Traditional 32 Forms', description: 'இருபுறமும் லட்சுமி தேவியருடன் சகல ஐஸ்வர்யங்களும் வாரி வழங்கும் வடிவம்.'),
    DeityFormItem(id: 13, nameEn: 'Maha Ganapati', nameTa: 'மகா கணபதி', type: 'Traditional 32 Forms', description: 'பத்து கரங்களுடன் செந்நிற மேனியில் முழுமுதற் கடவுளாய் விளங்கும் வடிவம்.'),
    DeityFormItem(id: 14, nameEn: 'Vijaya Ganapati', nameTa: 'விஜய கணபதி', type: 'Traditional 32 Forms', description: 'எடுத்த காரியங்கள் அனைத்திலும் உறுதியான வெற்றியை அருளும் வடிவம்.'),
    DeityFormItem(id: 15, nameEn: 'Nritya Ganapati', nameTa: 'நிருத்த கணபதி', type: 'Traditional 32 Forms', description: 'கற்பக மரத்தடியில் ஒற்றைக் காலைத் தூக்கி ஆனந்த நடனமாடும் வடிவம்.'),
    DeityFormItem(id: 16, nameEn: 'Urdhva Ganapati', nameTa: 'ஊர்த்துவ கணபதி', type: 'Traditional 32 Forms', description: 'தாமரை மலரில் சக்தி தேவியுடன் யோக சமாதியில் உயர்ந்திருக்கும் வடிவம்.'),
    DeityFormItem(id: 17, nameEn: 'Ekakshara Ganapati', nameTa: 'ஏகாக்ஷர கணபதி', type: 'Traditional 32 Forms', description: 'கம்பீரமான "ஓம்" என்னும் பிரணவ ஒற்றை எழுத்து தத்துவ வடிவம்.'),
    DeityFormItem(id: 18, nameEn: 'Varada Ganapati', nameTa: 'வரத கணபதி', type: 'Traditional 32 Forms', description: 'நெற்றியில் மூன்றாம் கண்ணுடன் அடியார்களுக்கு கேட்ட வரங்களை நல்கும் வடிவம்.'),
    DeityFormItem(id: 19, nameEn: 'Tryakshara Ganapati', nameTa: 'திரியாக்ஷர கணபதி', type: 'Traditional 32 Forms', description: 'அ, உ, ம என்ற மூன்று அட்சரங்களின் வடிவாக மோதகம் ஏந்திய வடிவம்.'),
    DeityFormItem(id: 20, nameEn: 'Kshipra Prasada Ganapati', nameTa: 'க்ஷிப்ர பிரசாத கணபதி', type: 'Traditional 32 Forms', description: 'புற்களால் ஆன ஆசனத்தில் அமர்ந்து அடியார்களின் பிழைகளை மன்னித்து பிரசன்னமாகும் வடிவம்.'),
    DeityFormItem(id: 21, nameEn: 'Haridra Ganapati', nameTa: 'ஹரித்ரா கணபதி', type: 'Traditional 32 Forms', description: 'மஞ்சள் நிற மேனியில் மஞ்சள் பட்டாடையுடன் சர்வ மங்களங்களை அளிப்பவர்.'),
    DeityFormItem(id: 22, nameEn: 'Ekadanta Ganapati', nameTa: 'ஏகதந்த கணபதி', type: 'Traditional 32 Forms', description: 'தனது உடைந்த தந்தத்தால் மகாபாரதத்தை எழுதிய ஞானத் திருமேனி.'),
    DeityFormItem(id: 23, nameEn: 'Srishti Ganapati', nameTa: 'சிருஷ்டி கணபதி', type: 'Traditional 32 Forms', description: 'மூஷிக வாகனத்தில் அமர்ந்து அண்ட சராசரங்களைப் படைக்கும் ஆற்றல் வடிவம்.'),
    DeityFormItem(id: 24, nameEn: 'Uddanda Ganapati', nameTa: 'உத்தண்ட கணபதி', type: 'Traditional 32 Forms', description: 'பன்னிரண்டு கரங்களுடன் தீய சக்திகளை அழித்து தர்மத்தை நிலைநாட்டும் வடிவம்.'),
    DeityFormItem(id: 25, nameEn: 'Rinamochana Ganapati', nameTa: 'ரிணமோசன கணபதி', type: 'Traditional 32 Forms', description: 'கடன் தொல்லைகள், பாவங்கள், பிறவிப் பிணிகளில் இருந்து விடுதலை அளிக்கும் வடிவம்.'),
    DeityFormItem(id: 26, nameEn: 'Dhundhi Ganapati', nameTa: 'துண்டி கணபதி', type: 'Traditional 32 Forms', description: 'காசி மாநகரில் சிவபெருமானால் பூஜிக்கப்பட்ட ருத்ராட்ச மாலை ஏந்திய வடிவம்.'),
    DeityFormItem(id: 27, nameEn: 'Dvimukha Ganapati', nameTa: 'துவிமுக கணபதி', type: 'Traditional 32 Forms', description: 'இரு திருமுகங்களுடன் அகம் மற்றும் புறம் இரண்டையும் காக்கும் வடிவம்.'),
    DeityFormItem(id: 28, nameEn: 'Trimukha Ganapati', nameTa: 'திரிமுக கணபதி', type: 'Traditional 32 Forms', description: 'மூன்று முகங்களுடன் முக்காலங்களையும் உணர்த்தும் தத்துவ வடிவம்.'),
    DeityFormItem(id: 29, nameEn: 'Simha Ganapati', nameTa: 'சிம்ம கணபதி', type: 'Traditional 32 Forms', description: 'சிங்க முகத்துடன் சிங்கத்தின் மீது கம்பீரமாக அமர்ந்து தைரியம் அருளும் வடிவம்.'),
    DeityFormItem(id: 30, nameEn: 'Yoga Ganapati', nameTa: 'யோக கணபதி', type: 'Traditional 32 Forms', description: 'யோக முத்திரையுடன் தியானத்தில் ஆழ்ந்திருக்கும் யோகீஸ்வரர் வடிவம்.'),
    DeityFormItem(id: 31, nameEn: 'Durga Ganapati', nameTa: 'துர்க்கா கணபதி', type: 'Traditional 32 Forms', description: 'துர்க்கையின் போர்க்கள கொடி மற்றும் ஆயுதங்கள் ஏந்திய வெற்றி வடிவம்.'),
    DeityFormItem(id: 32, nameEn: 'Sankatahara Ganapati', nameTa: 'சங்கடஹர கணபதி', type: 'Traditional 32 Forms', description: 'சங்கடங்களை அடியோடு தகர்த்து அடியார்களுக்கு சர்வ சுகமளிக்கும் சங்கடஹர சதுர்த்தி நாயகன்.'),
  ];

  // Associated Deities / Consorts (Stored separately from forms!)
  static const List<String> associatedConsorts = [
    'சித்தி (Siddhi)',
    'புத்தி (Buddhi)',
    'சித்தி & புத்தி (Siddhi & Buddhi)',
    'வல்லபை (Vallabhai)',
  ];
}
