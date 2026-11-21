// Master data and structured models for Primary Deity (Lord Shiva example)
// Supports:
// - Photo References (Primary photo & multiple form photos)
// - 63 Nayanmars (Traditional Shaivite Saints)
// - 18 Siddhars & Configurable Siddhar Traditions
// - Family Relationships (Consort, Sons, Daughters, etc.)
// - 12 Primary Shiva Forms & 64 Murtis
// - Configurable Deity Role / Gender

class PhotoReferenceRecord {
  final String id;
  final String deityId;
  final String targetType; // 'primary' or 'form'
  final String targetName;
  final String? photoBase64;
  final String? photoUrl;
  final String description;
  final DateTime createdAt;

  const PhotoReferenceRecord({
    required this.id,
    required this.deityId,
    required this.targetType,
    required this.targetName,
    this.photoBase64,
    this.photoUrl,
    this.description = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deityId': deityId,
    'targetType': targetType,
    'targetName': targetName,
    'photoBase64': photoBase64 ?? '',
    'photoUrl': photoUrl ?? '',
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PhotoReferenceRecord.fromJson(Map<String, dynamic> json) => PhotoReferenceRecord(
    id: json['id']?.toString() ?? '',
    deityId: json['deityId']?.toString() ?? 'shiva',
    targetType: json['targetType']?.toString() ?? 'primary',
    targetName: json['targetName']?.toString() ?? '',
    photoBase64: json['photoBase64']?.toString(),
    photoUrl: json['photoUrl']?.toString(),
    description: json['description']?.toString() ?? '',
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
  );

  PhotoReferenceRecord copyWith({
    String? id,
    String? deityId,
    String? targetType,
    String? targetName,
    String? photoBase64,
    String? photoUrl,
    String? description,
    DateTime? createdAt,
  }) => PhotoReferenceRecord(
    id: id ?? this.id,
    deityId: deityId ?? this.deityId,
    targetType: targetType ?? this.targetType,
    targetName: targetName ?? this.targetName,
    photoBase64: photoBase64 ?? this.photoBase64,
    photoUrl: photoUrl ?? this.photoUrl,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
  );
}

class NayanmarRecord {
  final String id;
  final String primaryDeityId;
  final String tamilName;
  final String englishName;
  final String relationshipType;
  final String shortDescription;
  final String photo;
  final String? photoBase64;

  const NayanmarRecord({
    required this.id,
    this.primaryDeityId = 'shiva',
    required this.tamilName,
    required this.englishName,
    this.relationshipType = 'Shaivite Saint / Devotee of Shiva',
    required this.shortDescription,
    this.photo = '',
    this.photoBase64,
  });

  String get displayName => '$tamilName ($englishName)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryDeityId': primaryDeityId,
    'tamilName': tamilName,
    'englishName': englishName,
    'relationshipType': relationshipType,
    'shortDescription': shortDescription,
    'photo': photo,
    'photoBase64': photoBase64 ?? '',
  };

  factory NayanmarRecord.fromJson(Map<String, dynamic> json) => NayanmarRecord(
    id: json['id']?.toString() ?? '',
    primaryDeityId: json['primaryDeityId']?.toString() ?? 'shiva',
    tamilName: json['tamilName']?.toString() ?? '',
    englishName: json['englishName']?.toString() ?? '',
    relationshipType: json['relationshipType']?.toString() ?? 'Shaivite Saint / Devotee of Shiva',
    shortDescription: json['shortDescription']?.toString() ?? '',
    photo: json['photo']?.toString() ?? '',
    photoBase64: json['photoBase64']?.toString(),
  );

  NayanmarRecord copyWith({
    String? id,
    String? primaryDeityId,
    String? tamilName,
    String? englishName,
    String? relationshipType,
    String? shortDescription,
    String? photo,
    String? photoBase64,
  }) => NayanmarRecord(
    id: id ?? this.id,
    primaryDeityId: primaryDeityId ?? this.primaryDeityId,
    tamilName: tamilName ?? this.tamilName,
    englishName: englishName ?? this.englishName,
    relationshipType: relationshipType ?? this.relationshipType,
    shortDescription: shortDescription ?? this.shortDescription,
    photo: photo ?? this.photo,
    photoBase64: photoBase64 ?? this.photoBase64,
  );
}

class SiddharRecord {
  final String id;
  final String primaryDeityId;
  final String tamilName;
  final String englishName;
  final String siddharTradition;
  final String shortDescription;
  final String photo;
  final String? photoBase64;

  const SiddharRecord({
    required this.id,
    this.primaryDeityId = 'shiva',
    required this.tamilName,
    required this.englishName,
    required this.siddharTradition,
    required this.shortDescription,
    this.photo = '',
    this.photoBase64,
  });

  String get displayName => '$tamilName ($englishName)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryDeityId': primaryDeityId,
    'tamilName': tamilName,
    'englishName': englishName,
    'siddharTradition': siddharTradition,
    'shortDescription': shortDescription,
    'photo': photo,
    'photoBase64': photoBase64 ?? '',
  };

  factory SiddharRecord.fromJson(Map<String, dynamic> json) => SiddharRecord(
    id: json['id']?.toString() ?? '',
    primaryDeityId: json['primaryDeityId']?.toString() ?? 'shiva',
    tamilName: json['tamilName']?.toString() ?? '',
    englishName: json['englishName']?.toString() ?? '',
    siddharTradition: json['siddharTradition']?.toString() ?? '18 Siddhars (பதினெண் சித்தர்கள்)',
    shortDescription: json['shortDescription']?.toString() ?? '',
    photo: json['photo']?.toString() ?? '',
    photoBase64: json['photoBase64']?.toString(),
  );

  SiddharRecord copyWith({
    String? id,
    String? primaryDeityId,
    String? tamilName,
    String? englishName,
    String? siddharTradition,
    String? shortDescription,
    String? photo,
    String? photoBase64,
  }) => SiddharRecord(
    id: id ?? this.id,
    primaryDeityId: primaryDeityId ?? this.primaryDeityId,
    tamilName: tamilName ?? this.tamilName,
    englishName: englishName ?? this.englishName,
    siddharTradition: siddharTradition ?? this.siddharTradition,
    shortDescription: shortDescription ?? this.shortDescription,
    photo: photo ?? this.photo,
    photoBase64: photoBase64 ?? this.photoBase64,
  );
}

class DeityFamilyRelationshipRecord {
  final String id;
  final String primaryDeityId;
  final String deityNameTa;
  final String deityNameEn;
  final String relationshipType; // Father, Mother, Son, Daughter, Husband, Wife / Consort, Brother, Sister, Other
  final String gender; // Male deity, Female deity, Both / Combined form, Other / Not specified
  final String description;
  final String photo;
  final String? photoBase64;

  const DeityFamilyRelationshipRecord({
    required this.id,
    this.primaryDeityId = 'shiva',
    required this.deityNameTa,
    required this.deityNameEn,
    required this.relationshipType,
    required this.gender,
    this.description = '',
    this.photo = '',
    this.photoBase64,
  });

  String get displayName => '$deityNameTa ($deityNameEn) - $relationshipType';

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryDeityId': primaryDeityId,
    'deityNameTa': deityNameTa,
    'deityNameEn': deityNameEn,
    'relationshipType': relationshipType,
    'gender': gender,
    'description': description,
    'photo': photo,
    'photoBase64': photoBase64 ?? '',
  };

  factory DeityFamilyRelationshipRecord.fromJson(Map<String, dynamic> json) => DeityFamilyRelationshipRecord(
    id: json['id']?.toString() ?? '',
    primaryDeityId: json['primaryDeityId']?.toString() ?? 'shiva',
    deityNameTa: json['deityNameTa']?.toString() ?? json['tamilName']?.toString() ?? '',
    deityNameEn: json['deityNameEn']?.toString() ?? json['englishName']?.toString() ?? '',
    relationshipType: json['relationshipType']?.toString() ?? 'Other',
    gender: json['gender']?.toString() ?? 'Other / Not specified',
    description: json['description']?.toString() ?? '',
    photo: json['photo']?.toString() ?? '',
    photoBase64: json['photoBase64']?.toString(),
  );

  DeityFamilyRelationshipRecord copyWith({
    String? id,
    String? primaryDeityId,
    String? deityNameTa,
    String? deityNameEn,
    String? relationshipType,
    String? gender,
    String? description,
    String? photo,
    String? photoBase64,
  }) => DeityFamilyRelationshipRecord(
    id: id ?? this.id,
    primaryDeityId: primaryDeityId ?? this.primaryDeityId,
    deityNameTa: deityNameTa ?? this.deityNameTa,
    deityNameEn: deityNameEn ?? this.deityNameEn,
    relationshipType: relationshipType ?? this.relationshipType,
    gender: gender ?? this.gender,
    description: description ?? this.description,
    photo: photo ?? this.photo,
    photoBase64: photoBase64 ?? this.photoBase64,
  );
}

class DeityFormRecord {
  final String id;
  final String primaryDeityId;
  final String nameTa;
  final String nameEn;
  final String description;
  final String photo;
  final String? photoBase64;
  final String? photoRefId;

  const DeityFormRecord({
    required this.id,
    this.primaryDeityId = 'shiva',
    required this.nameTa,
    required this.nameEn,
    required this.description,
    this.photo = '',
    this.photoBase64,
    this.photoRefId,
  });

  String get displayName => '$nameTa ($nameEn)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'primaryDeityId': primaryDeityId,
    'nameTa': nameTa,
    'nameEn': nameEn,
    'description': description,
    'photo': photo,
    'photoBase64': photoBase64 ?? '',
    'photoRefId': photoRefId ?? '',
  };

  factory DeityFormRecord.fromJson(Map<String, dynamic> json) => DeityFormRecord(
    id: json['id']?.toString() ?? '',
    primaryDeityId: json['primaryDeityId']?.toString() ?? 'shiva',
    nameTa: json['nameTa']?.toString() ?? '',
    nameEn: json['nameEn']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    photo: json['photo']?.toString() ?? '',
    photoBase64: json['photoBase64']?.toString(),
    photoRefId: json['photoRefId']?.toString(),
  );

  DeityFormRecord copyWith({
    String? id,
    String? primaryDeityId,
    String? nameTa,
    String? nameEn,
    String? description,
    String? photo,
    String? photoBase64,
    String? photoRefId,
  }) => DeityFormRecord(
    id: id ?? this.id,
    primaryDeityId: primaryDeityId ?? this.primaryDeityId,
    nameTa: nameTa ?? this.nameTa,
    nameEn: nameEn ?? this.nameEn,
    description: description ?? this.description,
    photo: photo ?? this.photo,
    photoBase64: photoBase64 ?? this.photoBase64,
    photoRefId: photoRefId ?? this.photoRefId,
  );
}

// Master lists and configurations
class ShivaAssociatedMasterData {
  static const List<String> relationshipTypes = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Husband',
    'Wife / Consort',
    'Brother',
    'Sister',
    'Other',
  ];

  static const List<String> genderRoleOptions = [
    'Male deity',
    'Female deity',
    'Both / Combined form',
    'Other / Not specified',
  ];

  // STEP 4 Canonical Family Relations for Shiva
  static const List<DeityFamilyRelationshipRecord> defaultShivaFamily = [
    DeityFamilyRelationshipRecord(
      id: 'family_parvati',
      primaryDeityId: 'shiva',
      deityNameTa: 'பார்வதி / உமாதேவி',
      deityNameEn: 'Parvati / Uma',
      relationshipType: 'Wife / Consort',
      gender: 'Female deity',
      description: 'சிவபெருமானின் துணைவி, ஆதி பராசக்தி, உலகிற்கெல்லாம் அன்னையாக விளங்கும் அம்பாள்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFamilyRelationshipRecord(
      id: 'family_murugan',
      primaryDeityId: 'shiva',
      deityNameTa: 'முருகன் / சுப்பிரமணியர்',
      deityNameEn: 'Murugan / Subrahmanya',
      relationshipType: 'Son',
      gender: 'Male deity',
      description: 'சிவனின் நெற்றிக்கண்ணில் இருந்து உதித்த ஞானக் கடவுள், தேவ சேனாதிபதி, தமிழ் கடவுள்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFamilyRelationshipRecord(
      id: 'family_vinayagar',
      primaryDeityId: 'shiva',
      deityNameTa: 'விநாயகர் / கணபதி',
      deityNameEn: 'Vinayagar / Ganesha',
      relationshipType: 'Son',
      gender: 'Male deity',
      description: 'முழுமுதற் கடவுள், தடைகளை நீக்குபவர், சிவபெருமான் மற்றும் உமாதேவியின் மூத்த மைந்தன்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
  ];

  // STEP 5: 12 Prominent Shiva Forms specifically required
  static const List<DeityFormRecord> prominent12ShivaForms = [
    DeityFormRecord(
      id: 'shiva_form_nataraja',
      primaryDeityId: 'shiva',
      nameTa: 'நடராஜர் (Nataraja)',
      nameEn: 'Nataraja',
      description: 'ஆனந்த தாண்டவ மூர்த்தி, பஞ்சகிருத்தியங்களை (படைத்தல், காத்தல், அழித்தல், மறைத்தல், அருளல்) புரியும் நடனக் கடவுள்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_dakshinamurthy',
      primaryDeityId: 'shiva',
      nameTa: 'தட்சிணாமூர்த்தி (Dakshinamurthy)',
      nameEn: 'Dakshinamurthy',
      description: 'தென்முகக் கடவுள், கல்லால மரத்தடியில் சனகாதி முனிவர்களுக்கு மௌன முத்திரையால் (சின்முத்திரை) பிரம்ம ஞானத்தை போதிக்கும் ஞானகுரு.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_lingodbhava',
      primaryDeityId: 'shiva',
      nameTa: 'லிங்கோற்பவர் (Lingodbhava)',
      nameEn: 'Lingodbhava',
      description: 'அடிமுடி காணா ஜோதிப் பிழம்பாய் பிரம்மாவுக்கும் விஷ்ணுவுக்கும் காட்சியளித்த எல்லையற்ற மூலப் பரம்பொருள் வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_ardhanarishvara',
      primaryDeityId: 'shiva',
      nameTa: 'அர்த்தநாரீஸ்வரர் (Ardhanarishvara)',
      nameEn: 'Ardhanarishvara',
      description: 'வலப்பக்கம் சிவனும் இடப்பக்கம் பார்வதியுமாய் விளங்கும் ஆதி ஆணும் பெண்ணும் இணைந்த பிரிக்க முடியாத சிவசக்தி ஐக்கிய வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_bhairava',
      primaryDeityId: 'shiva',
      nameTa: 'பைரவர் (Bhairava)',
      nameEn: 'Bhairava',
      description: 'காலத்தின் அதிபதி, சிவாலயங்களின் காவல் தெய்வம், பயங்களை நீக்கி நவகிரக தோஷங்களை அகற்றும் உக்கிர சாந்த வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_chandrashekara',
      primaryDeityId: 'shiva',
      nameTa: 'சந்திரசேகரர் (Chandrashekara)',
      nameEn: 'Chandrashekara',
      description: 'தேய்பிறை சாபத்தால் தஞ்சம் புகுந்த சந்திரனுக்கு அபயம் அளித்து தனது திருமுடியில் சூடிக்கொண்ட கருணை வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_somaskanda',
      primaryDeityId: 'shiva',
      nameTa: 'சோமாஸ்கந்தர் (Somaskanda)',
      nameEn: 'Somaskanda',
      description: 'சிவன் (ச), உமாதேவி (உமை), குழந்தை முருகன் (ஸ்கந்தன்) ஆகியோர் நடுவில் வீற்றிருக்கும் ஆனந்த குடும்ப வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_gangadhara',
      primaryDeityId: 'shiva',
      nameTa: 'கங்காதரர் (Gangadhara)',
      nameEn: 'Gangadhara',
      description: 'விண்ணிலிருந்து பொங்கி வந்த கங்கையின் ஆவேசத்தைத் தனது ஒற்றை சடாமுடியில் தாங்கி பூமிக்கு சாந்தமாக வழங்கி அருளிய வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_tripurantaka',
      primaryDeityId: 'shiva',
      nameTa: 'திரிபுராந்தகர் (Tripurantaka)',
      nameEn: 'Tripurantaka',
      description: 'தாரகாட்சன், கமலாட்சன், வித்யுன்மாலி ஆகிய அசுரர்களின் மூன்று கோட்டைகளையும் புன்னகையினால் பொசுக்கிய வில்லாளி வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_kirata',
      primaryDeityId: 'shiva',
      nameTa: 'கிராத மூர்த்தி (Kirata)',
      nameEn: 'Kirata',
      description: 'வேடன் உருவெடுத்து அர்ஜுனனின் தவத்தையும் வீரத்தையும் சோதித்து, அவனுக்குப் பாசுபதாஸ்திரத்தை அருளிய மூர்த்தி.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_pashupati',
      primaryDeityId: 'shiva',
      nameTa: 'பசுபதி (Pashupati)',
      nameEn: 'Pashupati',
      description: 'சகல ஜீவராசிகளுக்கும் (பசுக்களுக்கும்) தலைவனாய் விளங்கி, மாயா பந்தங்களை (பாசம்) அறுத்து முக்தியளிக்கும் நாயகன்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
    DeityFormRecord(
      id: 'shiva_form_harihara',
      primaryDeityId: 'shiva',
      nameTa: 'ஹரிஹரன் / சங்கரநாராயணர் (Harihara)',
      nameEn: 'Harihara',
      description: 'வலப்பக்கம் சிவனும் (ஹரன்) இடப்பக்கம் விஷ்ணுவும் (ஹரி) இணைந்து "அரியும் சிவனும் ஒன்னு" என்ற அத்வைத உண்மையை உணர்த்தும் வடிவம்.',
      photo: 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    ),
  ];

  // STEP 3A: Complete 63 Traditional Nayanmars
  static const List<NayanmarRecord> all63Nayanmars = [
    NayanmarRecord(
      id: 'nayanmar_1',
      tamilName: 'திருநீலகண்ட நாயனார்',
      englishName: 'Tiruneelakanta Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சிதம்பரத்தில் வாழ்ந்த குயவர்; சிவபெருமான் மீது கொண்ட பக்தியாலும், திருநீலகண்டத்தின் மீதான ஆணையாலும் வாழ்நாள் முழுவதும் புலனடக்கம் காத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_2',
      tamilName: 'இயற்பகை நாயனார்',
      englishName: 'Iyarpahai Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'காவிரிப்பூம்பட்டினத்து வணிகர்; சிவ பக்தர் ஒருவர் கேட்டதற்காக தன் மனைவியையே மனமுவந்து ஈந்த இணையற்ற தியாகச் செல்வர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_3',
      tamilName: 'இளையான்குடி மாறநாயனார்',
      englishName: 'Ilayankudi Maranar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'கடும் வறுமையிலும் நள்ளிரவு மழையில் விதைத்த நெல்லை அள்ளி வந்து சிவ அடியாருக்கு அமுதளித்து முக்தி அடைந்த பெருந்தகையாளர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_4',
      tamilName: 'மெய்ப்பொருள் நாயனார்',
      englishName: 'Meiporul Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சேதி நாட்டு மன்னர்; தன்னை வஞ்சகமாகக் கொன்ற பகைவனையும் அவன் உடலில் அணிந்திருந்த திருநீற்றைக் கண்டு "மெய்ப்பொருள்" எனப் போற்றி காத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_5',
      tamilName: 'விறல்மிண்ட நாயனார்',
      englishName: 'Viralminda Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'செங்குன்றூரைச் சேர்ந்த வேளாளர்; அடியாரைப் பணியாத சுந்தரமூர்த்தி நாயனாரையும் சிவபெருமானையும் புறகணித்துப் பேசிய தீவிர அடியார் பக்தி கொண்டவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_6',
      tamilName: 'அமர்நீதி நாயனார்',
      englishName: 'Amarneethi Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பழையாறை வணிகர்; சிவபெருமான் அந்தணராக வந்து தந்த கோவணத்திற்கு ஈடாக தன் செல்வம் அனைத்தையும் தந்து தானும் தராசில் ஏறியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_7',
      tamilName: 'எறிபத்த நாயனார்',
      englishName: 'Eripatha Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'கருவூரில் சிவபூஜைக்கான பூக்கூடையைத் தள்ளிவிட்ட பட்டத்து யானையையும் பாகன்களையும் மழுவினால் கொன்று திருத்தொண்டு காத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_8',
      tamilName: 'ஏனாதிநாத நாயனார்',
      englishName: 'Enatinatha Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'வாள்வித்தை ஆசிரியர்; போரில் பகைவன் திருநீறு பூசி வந்ததைக் கண்டு அவனைத் தாக்காமல் வாளைத் தாழ்த்தி தன்னுயிரை ஈந்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_9',
      tamilName: 'கண்ணப்ப நாயனார்',
      englishName: 'Kannappa Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'காளஹஸ்தி நாதரின் திருக்கண்ணில் உதிரம் வழிந்தபோது தன் கண்களையே அம்பினால் பெயர்த்து அப்பிய தூய அன்பின் சிகரம்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_10',
      tamilName: 'குங்கிலியக்கலய நாயனார்',
      englishName: 'Kungiliyakalaya Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருக்கடவூரில் வறுமையிலும் குங்கிலியப் புகையிட்டு சிவதொண்டு செய்தவர்; சாய்ந்திருந்த திருப்பனந்தாள் லிங்கத்தைத் தன் கழுத்தில் கயிறுகட்டி நிமிர்த்தியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_11',
      tamilName: 'மானக்கஞ்சாற நாயனார்',
      englishName: 'Manakanchara Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'தனது மகளின் திருமண நாளன்றே சிவனடியாரின் பஞ்சவடிக்கு (பூணூல்) கூந்தல் கேட்டவுடன் சற்றும் தயங்காமல் வெட்டி அளித்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_12',
      tamilName: 'அரிவாட்டாய நாயனார்',
      englishName: 'Arivattaya Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'செந்நெல் அரிசி நைவேத்தியம் நிலத்தில் சிந்தியதால் தன் கழுத்தை அரிவாளால் அறுக்கத் துணிந்தவர்; சிவபெருமான் பூமியைப் பிளந்து கைநீட்டித் தடுத்தார்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_13',
      tamilName: 'ஆனாய நாயனார்',
      englishName: 'Anaya Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருமங்கலம் மேய்ப்பர்; வேய்ங்குழலில் ஐந்தெழுத்து மந்திரத்தை (நமசிவாய) இசைத்து பசுக்களையும் மான் புலி உள்ளிட்ட சகல உயிர்களையும் பரவசப்படுத்தியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_14',
      tamilName: 'மூர்த்தி நாயனார்',
      englishName: 'Murthi Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'மதுரையில் சந்தனம் கிடைக்காத போது தன் முழங்கையையே சந்தனக் கல்லில் தேய்த்து சிவனுக்குக் காப்பிட்டவர்; பின் பாண்டிய நாட்டின் மன்னரானார்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_15',
      tamilName: 'முருக நாயனார்',
      englishName: 'Muruga Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருப்புகலூர் வர்த்தமானீஸ்வரருக்கு தினசரி அதிகாலையில் நறுமண மலர்களைக் கொய்து தொடுத்து மாலையிட்டு வழிபட்டவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_16',
      tamilName: 'உருத்திரபசுபதி நாயனார்',
      englishName: 'Rudrapashupathi Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருத்தலையூரில் தாமரைத் தடாகத்தில் கழுத்தளவு நீரில் நின்றுகொண்டு இரவுபகலாக ருத்ர ஜபம் ஓதி இறைவனின் பேரருளைப் பெற்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_17',
      tamilName: 'திருநாளைப்போவார் (நந்தனார்)',
      englishName: 'Tirunalaippovar (Nandanar)',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'ஆதனூர் அடியார்; சிதம்பரம் தில்லை நடராஜரைக் காணத் தீச்சுடர் புகுந்து அந்தணராகப் புதுவடிவெடுத்து இறைவன் திருவடியில் கலந்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_18',
      tamilName: 'திருக்குறிப்புத்தொண்ட நாயனார்',
      englishName: 'Tiru Kurippu Thonda Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'காஞ்சிபுரத்து வண்ணார்; அடியாரின் கந்தைத் துணியைத் துவைத்துத் தர மழை பெய்து உலராததால் தன் தலையைக் கற்பாறையில் மோதி மாய்க்கத் துணிந்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_19',
      tamilName: 'சண்டேசுவர நாயனார்',
      englishName: 'Chandeshvara Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'மண்ணால் லிங்கம் செய்து பாலபிஷேகம் செய்தபோது அதை உதைத்த தந்தையின் காலையே வெட்டியவர்; சிவனின் சண்டீசப் பதவியைப் பெற்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_20',
      tamilName: 'திருநாவுக்கரசு நாயனார் (அப்பர்)',
      englishName: 'Tirunavukkarasar (Appar)',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சைவ சமயக் குரவர்களில் ஒருவர்; உழவாரப் பணியும் தேவாரப் பதிகங்களும் பாடி சைவத்தை நிலைநாட்டிய வாகீசர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_21',
      tamilName: 'குலச்சிறை நாயனார்',
      englishName: 'Kulachirrai Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பாண்டிய நாட்டின் தலைமை அமைச்சர்; மங்கையர்க்கரசியாரோடு இணைந்து திருஞானசம்பந்தரை அழைத்து வந்து மதுரையில் சைவம் தழைக்கச் செய்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_22',
      tamilName: 'பெருமிழலைக் குறும்ப நாயனார்',
      englishName: 'Perumizhalai Kurumba Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சுந்தரமூர்த்தி நாயனாரைத் தன் ஞானகுருவாகக் கொண்டு அவருடைய திருநாமத்தையே தியானித்து யோக மார்க்கத்தில் கயிலை எய்தியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_23',
      tamilName: 'காரைக்கால் அம்மையார்',
      englishName: 'Karaikkal Ammaiyar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'இறைவனிடம் பேய் வடிவம் பெற்று தலையாலே நடந்து கயிலாயத்திற்குச் சென்றவர்; திருவாலங்காட்டில் சிவனின் நடனத்தின் கீழ் அமர்ந்திருக்கும் பெரும் தாய்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_24',
      tamilName: 'அப்பூதி அடிகள்',
      englishName: 'Appoodi Adigal',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திங்களூரில் வாழ்ந்து, நேரில் காணாமலேயே அப்பர் பெருமானின் பெயரைத் தன் பிள்ளைகள் மற்றும் தர்ம சாலைகளுக்குச் சூட்டி வழிபட்ட குருபக்தர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_25',
      tamilName: 'திருநீலநக்க நாயனார்',
      englishName: 'Tiruneelanakka Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சாத்தமங்கை வேதியர்; சிவலிங்கத்தின் மீது விழுந்த சிலந்தியை அன்பு பொங்க வாய் வைத்து ஊதி நீக்கிய பெருந்தகை.',
    ),
    NayanmarRecord(
      id: 'nayanmar_26',
      tamilName: 'நமிநந்தியடிகள்',
      englishName: 'Nami Nandi Adigal',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவாரூர் தியாகராஜர் ஆலயத்தில் நெய் கிடைக்காத போதும் குளத்து நீரைக் கொண்டு திருவிளக்குகளை எரியச் செய்து அற்புதம் நிகழ்த்தியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_27',
      tamilName: 'திருஞானசம்பந்த நாயனார்',
      englishName: 'Tirugnanasambandar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சீர்காழியில் மூன்றாம் வயதில் உமாதேவியிடம் ஞானப்பால் உண்டு "தோடுடைய செவியன்" என முதல் தேவாரம் பாடிய குழந்தை ஞானியாளர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_28',
      tamilName: 'ஏயர்கோன் கலிக்காம நாயனார்',
      englishName: 'Eyarkon Kalikkama Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சுந்தரருக்காகச் சிவபெருமான் தூது சென்றதை ஏற்க முடியாமல் வருந்திய சேனாதிபதி; பின் சுந்தரரின் நட்பினால் சூலை நோய் நீங்கி முக்தி பெற்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_29',
      tamilName: 'திருமூல நாயனார்',
      englishName: 'Thirumoolar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பசுக்களுக்காக மூலன் உடம்பில் கூடுவிட்டுக் கூடுபாய்ந்து, ஆண்டிற்கு ஒரு பாடலாக மூவாயிரம் தமிழ் மந்திரங்களை (திருமந்திரம்) அருளிய யோகீஸ்வரர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_30',
      tamilName: 'தண்டியடிகள் நாயனார்',
      englishName: 'Dandi Adigal Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பார்வையற்ற நிலையிலும் திருவாரூர்க் குளத்தை ஆழப்படுத்தக் கயிறு கட்டி மண் சுமந்தவர்; இறைவனின் அருளால் கண்பார்வை பெற்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_31',
      tamilName: 'மூர்க்க நாயனார்',
      englishName: 'Murkhas Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவேற்காட்டில் வாழ்ந்து, சூதாட்டத்தில் வென்ற பொருளைக் கொண்டு சிவ அடியார்களுக்கு அறுசுவை உணவு படைத்து வந்த அடியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_32',
      tamilName: 'சோமாசிமாற நாயனார்',
      englishName: 'Somasi Mara Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவம்பலில் சோமயாகம் செய்து, அதில் சிவபெருமானையே நேரில் வரவழைத்து அவிப்பாகம் ஏற்றுக்கொள்ளச் செய்த வேள்விச் செல்வர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_33',
      tamilName: 'சாக்கிய நாயனார்',
      englishName: 'Sakkiya Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'தினமும் சிவலிங்கத்தின் மீது கல்லெறிந்து வழிபட்டவர்; இறைவன் அவரின் தூய அன்பை உணர்ந்து அந்த கற்களை மலர்களாக ஏற்று அருளினார்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_34',
      tamilName: 'சிறப்புலி நாயனார்',
      englishName: 'Sirappuli Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவாக்கூரில் பிறந்த வள்ளல்; தினசரி சிவனடியார்களுக்கு அமுதளித்து, அவர்களுக்கு வேண்டிய ஆடைகளையும் உதவிகளையும் குறைவின்றி வழங்கியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_35',
      tamilName: 'சிறுத்தொண்ட நாயனார்',
      englishName: 'Siruthondar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'வாதாபி வென்ற பரஞ்சோதியார்; சிவனடியாராக வந்த பைரவருக்குத் தன் ஒரே மகனான சீராளனை நைவேத்தியமாகப் படைக்கத் துணிந்த தியாகச் சிகரம்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_36',
      tamilName: 'சேரமான் பெருமாள் நாயனார்',
      englishName: 'Cheraman Perumal Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சேர மன்னர்; தில்லையம்பல கூத்தனின் சிலம்பொலியை தினசரி பூசையின் முடிவில் கேட்டு மகிழ்ந்தவர்; சுந்தரரோடு வெள்ளை யானையில் கயிலை சென்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_37',
      tamilName: 'கணநாத நாயனார்',
      englishName: 'Gananatha Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சீர்காழியில் தோட்டம் அமைத்தல், திருவிளக்கிடுதல், திருக்கோவில் தூய்மை செய்தல் ஆகிய பணிகளை அடியார்களுக்குக் கற்பித்து வழிநடத்தியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_38',
      tamilName: 'கூற்றுவ நாயனார்',
      englishName: 'Kootruva Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'களந்தை சிற்றரசர்; தில்லை அந்தணர்கள் முடிசூட்ட மறுத்தபோது நடராஜப் பெருமானின் பாதங்களையே தன் தலைக்கு மணிமுடியாகப் பெற்றவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_39',
      tamilName: 'புகழ்ச்சோழ நாயனார்',
      englishName: 'Pukazh Chola Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'உறையூர் சோழ மன்னர்; போர்க்களத்தில் விழுந்த தலைகளில் ஒன்றில் திருநீறு சடைமுடி இருப்பதைக் கண்டு மனம் தாளாது தீப்புகுந்து உயிர் துறந்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_40',
      tamilName: 'நரசிங்க முனையரையர்',
      englishName: 'Narasinga Muniyaraiyar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருமுனைப்பாடி அரசர்; திருநீறு பூசிய யாவரையும் சிவனாகவே பாவித்து சுந்தரரை வளர்த்த வளர்ப்புத் தந்தை.',
    ),
    NayanmarRecord(
      id: 'nayanmar_41',
      tamilName: 'அதிபத்த நாயனார்',
      englishName: 'Adipaththa Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'நாகப்பட்டினத்து மீனவர்; வலையில் சிக்கும் முதல் மீனைத் தினமும் சிவபெருமானுக்கு அர்ப்பணித்து கடலில் விட்டவர்; பொன் மீன் கிடைத்தபோதும் அற்பணித்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_42',
      tamilName: 'கலிக்கம்ப நாயனார்',
      englishName: 'Kalikkamba Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பெண்ணாகடத்தில் வாழ்ந்த வணிகர்; பழைய வேலையாள் சிவனடியாராகி வந்தபோது அவனுக்குப் பாதபூஜை செய்யத் தயங்கிய தன் மனைவியின் கையையே வெட்டியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_43',
      tamilName: 'கலிய நாயனார்',
      englishName: 'Kalia Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவொற்றியூர் செக்குத் தொழிலாளி; திருக்கோவில் விளக்கேற்ற எண்ணெய் வாங்கப் பணமில்லாத போது தன் உடம்பின் இரத்தத்தையே எண்ணெயாக ஊற்றியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_44',
      tamilName: 'சத்தி நாயனார்',
      englishName: 'Satti Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'வரிஞ்சையூர் அடியார்; சிவபெருமானையோ சிவனடியாரையோ நிந்தித்துப் பேசுவோரின் நாவைத் தனது குறட்டால் பிடித்து அறுத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_45',
      tamilName: 'ஐயடிகள் காடவர்கோன்',
      englishName: 'Aiyadigal Kadavarkon',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'காஞ்சி பல்லவ பேரரசர்; அரச பதவியைத் துறந்து திருத்தலங்கள் தோறும் யாத்திரை செய்து "க்ஷேத்திரத் திருவெண்பா" பாடிய துறவி மன்னர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_46',
      tamilName: 'கணம்புல்ல நாயனார்',
      englishName: 'Kanampulla Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'கணம்புல் அறுத்து விற்று விளக்கெரித்தவர்; புல் விற்காதபோது தன் தலைமுடியையே திரியாக்கி விளக்கேற்றி சிவகதி அடைந்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_47',
      tamilName: 'காரி நாயனார்',
      englishName: 'Kari Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருக்கடவூர் புலவர்; "காரிக்கோவை" என்னும் தமிழ் நூல்களை இயற்றிப் பெற்ற பெரும் பொன்னைக் கொண்டு சிவாலயங்களைப் புதுப்பித்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_48',
      tamilName: 'நின்றசீர் நெடுமாற நாயனார்',
      englishName: 'Ninrasir Nedumara Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'கூன் பாண்டியன்; திருஞானசம்பந்தரின் திருநீற்றுப் பதிகத்தால் வெப்புநோய் நீங்கி சைவம் தழுவி திருநெல்வேலி போரில் வென்ற பெருவேந்தர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_49',
      tamilName: 'மங்கையர்க்கரசியார்',
      englishName: 'Mangayarkkarasiyar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சோழ இளவரசி, பாண்டிய அரசி; சமணச் சூழலிலும் திருஞானசம்பந்தரை மதுரைக்கு அழைத்து வந்து தமிழ்நாட்டில் சைவத்தை மீட்டெடுத்த தாய்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_50',
      tamilName: 'இசைஞானியார்',
      englishName: 'Isaignaniyar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருநாவலூரில் சடைய நாயனாரின் துணைவியாராக விளங்கி, சைவத் திருத்தொண்டின் தலைமகன் சுந்தரமூர்த்தி நாயனாரைப் பெற்றெடுத்த தாயார்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_51',
      tamilName: 'சடைய நாயனார்',
      englishName: 'Sadaiya Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருநாவலூர் ஆதிசைவர்; சுந்தரமூர்த்தி நாயனாரின் தந்தையார்; இறைவனின் அடியார்களையே தனது இரு கண்களாகப் போற்றியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_52',
      tamilName: 'திருநீலகண்ட யாழ்ப்பாணர்',
      englishName: 'Tiruneelakanta Yazhpanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருவெருக்கத்தம்புலியூர் யாழிசை மாமன்னர்; திருஞானசம்பந்தரின் தேவாரப் பதிகங்களை தனது யாழில் மீட்டுக் கயிலை எய்திய இசைக் கலைஞர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_53',
      tamilName: 'சுந்தரமூர்த்தி நாயனார்',
      englishName: 'Sundaramurthi Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'தம்பிரான் தோழர்; திருவாரூரில் "திருத்தொண்டத் தொகை" பாடி 63 நாயன்மார்களின் பெருமைகளை உலகறியச் செய்த சிவநேசர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_54',
      tamilName: 'வாயிலார் நாயனார்',
      englishName: 'Vayilar Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'மயிலாப்பூர் அடியார்; உள்ளத்தையே கோவிலாக்கி, ஞானத்தை விளக்காக்கி, அன்பை நைவேத்தியமாக்கி மனதிற்குள் சிவபூஜை செய்த மௌன சித்தர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_55',
      tamilName: 'பூசலார் நாயனார்',
      englishName: 'Poosalar Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'திருநின்றவூரில் மனதாலேயே பிரம்மாண்ட கற்றளி அமைத்தவர்; காஞ்சி பல்லவ மன்னனின் கல் கோயிலைவிட இவர் மனக்கோவிலுக்கு இறைவன் முதலில் எழுந்தருளினார்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_56',
      tamilName: 'கோச்செங்கட் சோழ நாயனார்',
      englishName: 'Kochengat Chola Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'முற்பிறவியில் சிலந்தியாகி சிவலிங்கத்திற்குப் பந்தல் அமைத்தவர்; மறுபிறவியில் சோழ மன்னனாகி யானைகள் ஏற முடியாத 70 மாடக் கோயில்களைக் கட்டியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_57',
      tamilName: 'திருநீலகண்டத்து குயவனார் (நீலகண்டர்)',
      englishName: 'Tiruneelakantar (Chidambaram)',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'தில்லைவாழ் அந்தணர் பெருமை போற்றி இளமைத் துறவறம் பூண்டு திருநீலகண்ட நாம மகிமை காட்டியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_58',
      tamilName: 'புகழ்த்தூணை நாயனார்',
      englishName: 'Pukazhthunai Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'அரிசிற் புனல் சூழ்ந்த ஆளந்துறை அர்ச்சகர்; பஞ்ச காலத்திலும் நலிந்த உடலோடு பூஜை செய்த போது தினமும் இறைவன் பீடத்தில் காசு தந்து காத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_59',
      tamilName: 'கோட்புலி நாயனார்',
      englishName: 'Kotpuli Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'நாட்டியத்தான்குடி படைத்தலைவர்; பஞ்ச காலத்தில் சிவபூஜைக்கான நெல்லை உண்ட தன் உறவினர்கள் அனைவரையும் வாளினால் தண்டித்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_60',
      tamilName: 'செருத்துணை நாயனார்',
      englishName: 'Seruthunai Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'தஞ்சாவூர் அடியார்; திருவாரூர் மண்டபத்தில் சிவனுக்குச் சாத்த வைத்திருந்த மாலையை முகர்ந்து பார்த்த பல்லவ அரசியின் மூக்கையே அறுத்தவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_61',
      tamilName: 'கழற்சிங்க நாயனார்',
      englishName: 'Kazharsinga Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'பல்லவ பேரரசர்; தன் பட்டத்து அரசி சிவமலரை முகர்ந்ததற்கு மூக்கையறுத்த செருத்துணையாரைப் பாராட்டி, பூவை எடுத்த அரசியின் கையையும் வெட்டியவர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_62',
      tamilName: 'கழறிற்றறிவார் நாயனார்',
      englishName: 'Kazharittrarivar Nayanar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சேர வேந்தர்; சகல ஜீவராசிகளின் மொழிகளையும் அறிந்தவர்; சுந்தரமூர்த்தி நாயனாரின் ஆருயிர் நண்பராய் விளங்கிய மாமன்னர்.',
    ),
    NayanmarRecord(
      id: 'nayanmar_63',
      tamilName: 'மாணிக்கவாசக நாயனார்',
      englishName: 'Manikkavacakar',
      relationshipType: 'Shaivite Saint / Devotee of Shiva',
      shortDescription: 'சைவ சமயக் குரவர்களில் நால்வரில் ஒருவர்; "திருவாசகத்திற்கு உருகார் ஒரு வாசகத்திற்கும் உருகார்" என்ற புகழ் கொண்ட தில்லைப் பெருமானின் அன்பர்.',
    ),
  ];

  // STEP 3B: Canonical 18 Traditional Siddhars
  static const List<SiddharRecord> traditional18Siddhars = [
    SiddharRecord(
      id: 'siddhar_1',
      tamilName: 'அகத்தியர்',
      englishName: 'Agathiyar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'முதல் சித்தர், தமிழ் முனிவர், அகத்திய நாடி மற்றும் சித்த மருத்துவத்தின் மூலத் தந்தை; பொதிகை மலையில் வாழ்பவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_2',
      tamilName: 'போகர்',
      englishName: 'Bogar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'பழனி முருகன் நவபாஷாண திருமேனியை வடித்த சித்தர், காயகற்ப ரசவாத வித்தைகளின் பெரும் ஆசான்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_3',
      tamilName: 'திருமூலர்',
      englishName: 'Thirumoolar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: '"ஒன்றே குலமும் ஒருவனே தேவனும்", "அன்பே சிவம்" என திருமந்திரம் இயற்றிய மகா யோகி.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_4',
      tamilName: 'கோரக்கர்',
      englishName: 'Korakkar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'மூலிகைகள், ரசவாதம் மற்றும் தத்துவ ஞான பாடல்களை அருளியவர்; வெள்ளியங்கிரி மற்றும் பொய்கைநல்லூரில் ஜீவசமாதி கொண்டவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_5',
      tamilName: 'கருவூரார்',
      englishName: 'Karuvoorar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'தஞ்சாவூர் பிரகதீஸ்வரர் பெரிய கோவிலின் ஸ்தபதி மற்றும் அஷ்டபந்தன மருந்து சாத்திய சித்தர் குரு.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_6',
      tamilName: 'இடைக்காடர்',
      englishName: 'Idai Kaadar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'வானியல் ஜோதிட ஞான சித்தர்; திருவண்ணாமலையில் தவம் செய்து வரவிருக்கும் பஞ்சங்களை முன்கூட்டியே கணித்த ஞானி.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_7',
      tamilName: 'புலிப்பாணி',
      englishName: 'Pulipani',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'போகரின் முதன்மை சீடர்; புலியின் மீது அமர்ந்து பயணம் செய்த பெரும் மாந்திரீக, மூலிகை சிகிச்சை சித்தர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_8',
      tamilName: 'சட்டமுனி',
      englishName: 'Sattamuni',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'வாத காவியம், சூட்சும ஞான நூல்களை இயற்றியவர்; திருவரங்கத்தில் ஜீவசமாதி அடைந்த சித்தர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_9',
      tamilName: 'சுந்தரானந்தர்',
      englishName: 'Sundaranandar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'மதுரை மீனாட்சி சுந்தரேஸ்வரர் திருக்கோவிலில் ஜீவசமாதி பூண்டவர்; சோதிடத்திலும் ரசவாதத்திலும் வல்லவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_10',
      tamilName: 'கொங்கணர்',
      englishName: 'Konganar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'கொங்கு நாட்டில் தவமியற்றி கொக்குகளை தன் விழிப்பார்வையால் சுட்டவர்; திருப்பதியில் தவம் செய்த சித்தர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_11',
      tamilName: 'கமலமுனி',
      englishName: 'Kamalamuni',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'திருவாரூர் தியாகராஜர் ஆலய வளாகத்தில் சமாதி கொண்டவர்; குண்டலினி யோக சூட்சுமங்களை அருளிய முனிவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_12',
      tamilName: 'தன்வந்திரி',
      englishName: 'Dhanvantari',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'ஆயுர்வேத மருத்துவத்தின் தெய்வீக சித்தர்; வைத்தீஸ்வரன் கோவிலில் ஜீவசமாதி கொண்டவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_13',
      tamilName: 'வான்மீகி',
      englishName: 'Valmiki',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'ராமாயண காவியத்தை வடித்த மகரிஷி; எட்டிகுடியில் சமாதி கொண்ட சித்தர் மரபின் ஜோதி.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_14',
      tamilName: 'பதஞ்சலி',
      englishName: 'Pathanjali',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'யோக சூத்திரங்களை உலகுக்குத் தந்த ஆதிசேஷ அவதாரம்; தில்லையில் சிவனின் ஆனந்த நடனம் கண்டவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_15',
      tamilName: 'குதம்பைச் சித்தர்',
      englishName: 'Kudambai Siddhar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: '"குதம்பாய்" என மகளிரை விளித்துப் பாடி அத்துவைத ஞானத்தை எளிமையாகப் புகட்டிய ஞானியாளர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_16',
      tamilName: 'அழுகண்ணிச் சித்தர்',
      englishName: 'Azhuganni Siddhar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'இறைவனின் திருவருளுக்காக கண்ணீர் வடித்துத் தன் பாடல்களில் உருகி ஞானம் எய்திய சித்தர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_17',
      tamilName: 'பாம்பாட்டிச் சித்தர்',
      englishName: 'Paambatti Siddhar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'குண்டலினி சக்தியைப் பாம்பாக உருவகித்து மனதை அடக்கும் ஞானப் பாடல்களை அருளிய யோகி.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
    SiddharRecord(
      id: 'siddhar_18',
      tamilName: 'கடுவெளிச் சித்தர்',
      englishName: 'Kaduveli Siddhar',
      siddharTradition: '18 Siddhars (பதினெண் சித்தர்கள்)',
      shortDescription: 'வெட்டவெளியையே சிவனாகக் கண்டு உபாசனை செய்த ஞானியாளர்; "நந்தவனத்தில் ஓர் ஆண்டி" பாடலை இயற்றியவர்.',
      photo: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=500&q=60',
    ),
  ];

  // Optional regional/traditional Siddhars
  static const List<SiddharRecord> otherTraditionalSiddhars = [
    SiddharRecord(
      id: 'siddhar_other_1',
      tamilName: 'சிவவாக்கியர்',
      englishName: 'Siva Vakkiyar',
      siddharTradition: 'Tamil Siddhar Tradition (தமிழ் சித்தர் மரபு)',
      shortDescription: 'மூடநம்பிக்கைகளை உடைத்து உருவமற்ற ஜோதி வழிபாட்டை வலியுறுத்திய தீவிர ஞானப் பாடகர்.',
    ),
    SiddharRecord(
      id: 'siddhar_other_2',
      tamilName: 'மச்சமுனி',
      englishName: 'Machamuni',
      siddharTradition: 'Nath Siddhar Tradition (நாத மரபு)',
      shortDescription: 'மீன் வயிற்றில் இருந்து உதித்தவராகக் கூறப்படும் நாத சித்த மரபின் மகா குரு மச்சேந்திரநாத்.',
    ),
    SiddharRecord(
      id: 'siddhar_other_3',
      tamilName: 'காகபுசுண்டர்',
      englishName: 'Kakabusundar',
      siddharTradition: 'Ancient Siddhar Tradition (ஆதி சித்தர் மரபு)',
      shortDescription: 'யுகங்களைக் கடந்து வாழும் காக வடிவிலான சித்த முனிவர், பிரணவ மந்திரத்தின் ஆசான்.',
    ),
  ];

  static const List<String> siddharTraditionOptions = [
    '18 Siddhars (பதினெண் சித்தர்கள்)',
    'Tamil Siddhar Tradition (தமிழ் சித்தர் மரபு)',
    'Nath Siddhar Tradition (நாத மரபு)',
    'Regional Siddhar Tradition (வட்டாரச் சித்தர் மரபு)',
    'Other Tradition (இதர மரபு)',
  ];
}
