// Complete Traditional 64 Shiva Murtis (அறுபத்து நான்கு சிவ மூர்த்தங்கள்) Master Dataset
// Reference: Shaiva Agamas (Kamika, Karana), Thiruvilaiyadal Puranam, Shaiva Siddhanta

class ShivaMurtiModel {
  final int id;
  final String categoryId;
  final String categoryName;
  final String tamilName;
  final String englishName;
  final String genderClassification; // 'male', 'other', 'female'
  final String genderLabelTamil; // 'ஆண் தெய்வம்', 'மற்றவை (ஆண்-பெண் இணைவு)'
  final String formClassification; // 'அருவுருவம்', 'போகம்', 'யோகம்', 'சம்ஹாரம்', 'நிருத்தம்', 'அனுக்கிரகம்', 'சங்கரம்'
  final String parentDeity;
  final String defaultConsort;
  final String defaultRelationship;
  final String image;
  final String description;
  final String speciality;
  final String referenceSource;
  final bool isActive;

  const ShivaMurtiModel({
    required this.id,
    this.categoryId = 'shiva',
    this.categoryName = 'சிவன்',
    required this.tamilName,
    required this.englishName,
    required this.genderClassification,
    required this.genderLabelTamil,
    required this.formClassification,
    this.parentDeity = 'சிவபெருமான் (Lord Shiva)',
    this.defaultConsort = '',
    this.defaultRelationship = 'மூல பரம்பொருள் / தந்தை',
    this.image = 'https://images.unsplash.com/photo-1601058268499-e52658b88cb7?auto=format&fit=crop&w=500&q=60',
    required this.description,
    required this.speciality,
    this.referenceSource = 'காரணாகமம் & சைவ சித்தாந்தம் (Shaiva Agamas)',
    this.isActive = true,
  });

  String get displayName => '$tamilName – $englishName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'tamil_name': tamilName,
      'english_name': englishName,
      'gender_classification': genderClassification,
      'gender_label_tamil': genderLabelTamil,
      'form_classification': formClassification,
      'parent_deity': parentDeity,
      'default_consort': defaultConsort,
      'default_relationship': defaultRelationship,
      'image': image,
      'description': description,
      'speciality': speciality,
      'reference_source': referenceSource,
      'is_active': isActive,
    };
  }

  factory ShivaMurtiModel.fromJson(Map<String, dynamic> json) {
    return ShivaMurtiModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      categoryId: json['category_id']?.toString() ?? 'shiva',
      categoryName: json['category_name']?.toString() ?? 'சிவன்',
      tamilName: json['tamil_name']?.toString() ?? '',
      englishName: json['english_name']?.toString() ?? '',
      genderClassification: json['gender_classification']?.toString() ?? 'male',
      genderLabelTamil: json['gender_label_tamil']?.toString() ?? 'ஆண் தெய்வம்',
      formClassification: json['form_classification']?.toString() ?? 'சாந்த வடிவம்',
      parentDeity: json['parent_deity']?.toString() ?? 'சிவபெருமான் (Lord Shiva)',
      defaultConsort: json['default_consort']?.toString() ?? '',
      defaultRelationship: json['default_relationship']?.toString() ?? 'மூல பரம்பொருள் / தந்தை',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      speciality: json['speciality']?.toString() ?? '',
      referenceSource: json['reference_source']?.toString() ?? 'காரணாகமம் & சைவ சித்தாந்தம்',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }
}

class ShivaMurtisMasterData {
  static final List<ShivaMurtiModel> all64Murtis = [
    // 1. இலிங்க மூர்த்தி – Linga Murti
    const ShivaMurtiModel(
      id: 1,
      tamilName: 'இலிங்க மூர்த்தி',
      englishName: 'Linga Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம் (அருவுருவம்)',
      formClassification: 'அருவுருவ வடிவம் (Nishkala-Sakala)',
      defaultConsort: 'உமாதேவி (ஆவுடையார் வடிவம்)',
      description: 'சிவனின் ஆதியும் அந்தமும் இல்லா மூல அருவுருவத் திருமேனி. லிங்க பீடமும் ஆவுடையாரும் சிவசக்தி ஐக்கிய தத்துவத்தைக் குறிக்கிறது.',
      speciality: 'பாணலிங்கம், ஆவுடையார் கொண்ட மூலஸ்தான லிங்க வடிவம். பஞ்சபூதங்களில் அக்னி மற்றும் ஆகாய தத்துவத்தின் மூல வடிவம்.',
    ),

    // 2. இலிங்கோற்பவ மூர்த்தி – Lingodbhava Murti
    const ShivaMurtiModel(
      id: 2,
      tamilName: 'இலிங்கோற்பவ மூர்த்தி',
      englishName: 'Lingodbhava Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ஜோதிர்லிங்க வடிவம் (Pillar of Cosmic Light)',
      defaultConsort: 'பார்வதி',
      description: 'பிரம்மனும் மகாவிஷ்ணுவும் அடிமுடி காண முடியாதபடி அடிமுடியற்ற ஜோதிப் பிழம்பாக நீண்டெழுந்த பரமேசுவரனின் மகா திருவுருவம்.',
      speciality: 'லிங்கப் பிளவின் நடுவே சந்திரசேகரராக காட்சி தருதல், மேலே அன்னப்பறவை (பிரம்மா), கீழே வராக வடிவில் விஷ்ணு குடைதல்.',
    ),

    // 3. முகலிங்க மூர்த்தி – Mukhalinga Murti
    const ShivaMurtiModel(
      id: 3,
      tamilName: 'முகலிங்க மூர்த்தி',
      englishName: 'Mukhalinga Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'உருவ-அருவுருவ வடிவம் (Faced Linga)',
      defaultConsort: 'உமாதேவி',
      description: 'லிங்கத் திருமேனியின் முகப்பில் ஈசானம், தற்புருஷம், அகோரம், வாமதேவம் ஆகிய திருமுகங்கள் செதுக்கப்பட்ட திவ்ய தரிசனம்.',
      speciality: 'ஒன்று அல்லது நான்கு திருமுகங்கள் லிங்க பாணத்தில் பொறிக்கப்பட்ட வடிவம். திசைகளுக்கேற்ற சாந்த மற்றும் உக்கிர பாவங்கள்.',
    ),

    // 4. சதாசிவ மூர்த்தி – Sadashiva Murti
    const ShivaMurtiModel(
      id: 4,
      tamilName: 'சதாசிவ மூர்த்தி',
      englishName: 'Sadashiva Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'பஞ்சமுக வடிவம் (Five-Faced Transcendent)',
      defaultConsort: 'மனோன்மணி தேவி',
      description: 'ஐந்து திருமுகங்களும் பத்து திருக்கரங்களும் கொண்டு ஐந்தொழில்களை (படைத்தல், காத்தல், அழித்தல், மறைத்தல், அருளல்) நிகழ்த்தும் மூல மூர்த்தி.',
      speciality: 'ஈசானம், தற்புருஷம், அகோரம், வாமதேவம், சத்யோஜாதம் என்ற 5 முகங்கள். சூலம், பரசு, வஜ்ரம், அபயம், வரதம் முதலிய 10 ஆயுதங்கள்.',
    ),

    // 5. மகாசதாசிவ மூர்த்தி – Mahasadashiva Murti
    const ShivaMurtiModel(
      id: 5,
      tamilName: 'மகாசதாசிவ மூர்த்தி',
      englishName: 'Mahasadashiva Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'பேரொளி விஸ்வரூபம் (25-Faced Cosmic Form)',
      defaultConsort: 'மகாசக்தி',
      description: 'இருபத்தைந்து திருமுகங்களும் ஐம்பது திருக்கரங்களும் கொண்ட பரமேசுவரனின் பிரம்மாண்ட அண்ட சராசர விராட் திருவுருவம்.',
      speciality: '25 முகங்கள் அடுக்குகளாக அமைந்த விஸ்வரூப தரிசனம். சகல அஸ்திரங்களையும் ஏந்திய 50 திருக்கரங்கள்.',
    ),

    // 6. உமாமகேச மூர்த்தி – Uma Maheshwara Murti
    const ShivaMurtiModel(
      id: 6,
      tamilName: 'உமாமகேச மூர்த்தி',
      englishName: 'Uma Maheshwara Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (உமா சமேத தெய்வம் / Composite)',
      formClassification: 'போக மங்கள வடிவம் (Lord with Consort Uma)',
      defaultConsort: 'உமாதேவி',
      defaultRelationship: 'மனைவி (உடனுறை தேவி)',
      description: 'உமாதேவியுடன் சுகாசனத்தில் அமர்ந்து பக்தர்களுக்கு குடும்ப அமைதியும் சகல சௌபாக்கியங்களும் அருளும் மங்களகரமான திருமேனி.',
      speciality: 'இடது தொடையில் உமாதேவியை அமர்த்தி, இடது கரம் தேவியைத் தழுவியிருக்க, வலது கரம் அபய முத்திரையுடன் கூடிய வடிவம்.',
    ),

    // 7. சுகாசன மூர்த்தி – Sukhasana Murti
    const ShivaMurtiModel(
      id: 7,
      tamilName: 'சுகாசன மூர்த்தி',
      englishName: 'Sukhasana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சாந்த வடிவம் (Peaceful Seated Posture)',
      defaultConsort: 'பார்வதி',
      description: 'இடது காலை மடக்கி, வலது காலை தொங்கவிட்டு ஆசனத்தில் பேரமைதியோடு வீற்றிருக்கும் மங்கள திருவுருவம்.',
      speciality: 'மழு, மான் ஏந்திய நான்கு கரங்கள். முகம் பிரசன்ன புன்னகையுடன் கூடிய சாந்த சொரூபம்.',
    ),

    // 8. உமேச மூர்த்தி – Umesha Murti
    const ShivaMurtiModel(
      id: 8,
      tamilName: 'உமேச மூர்த்தி',
      englishName: 'Umesha Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (உமை உடனுறை மூர்த்தி)',
      formClassification: 'போக வடிவம் (Lord with Uma)',
      defaultConsort: 'உமாதேவி',
      defaultRelationship: 'மனைவி (உடனுறை தேவி)',
      description: 'உமையொருபாகனாக தேவியுடன் நின்ற திருக்கோலத்தில் அருள்பாலிக்கும் கருணா வடிவம்.',
      speciality: 'ஈசன் வலப்புறமும் தேவி இடப்புறமும் நின்ற கோலம். அடியவர்களுக்கு தீர்க்காயுளும் செல்வமும் அளிக்கும் திருமேனி.',
    ),

    // 9. சோமாஸ்கந்த மூர்த்தி – Somaskanda Murti
    const ShivaMurtiModel(
      id: 9,
      tamilName: 'சோமாஸ்கந்த மூர்த்தி',
      englishName: 'Somaskanda Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (சிவ-சக்தி-முருகன் குடும்ப வடிவம்)',
      formClassification: 'அருள் குடும்ப வடிவம் (Shiva, Uma, Skanda)',
      defaultConsort: 'உமாதேவி',
      defaultRelationship: 'உடனுறை தேவி மற்றும் குழந்தை முருகன்',
      description: 'சிவபெருமான், உமாதேவி இருவருக்கும் இடையே குழந்தை முருகப் பெருமான் நடனமாடும் ஆனந்த திருக்கோலம் (ச+உமா+ஸ்கந்த).',
      speciality: 'பல்லவ மற்றும் சோழர் ஆலயங்களின் கருவறைக்குப் பின்னால் வழிபடப்படும் மங்களகரமான குடும்ப அமைதி தரும் திருமேனி.',
    ),

    // 10. சந்திரசேகர மூர்த்தி – Chandrasekhara Murti
    const ShivaMurtiModel(
      id: 10,
      tamilName: 'சந்திரசேகர மூர்த்தி',
      englishName: 'Chandrasekhara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ரக்ஷக வடிவம் (Bearer of the Crescent Moon)',
      defaultConsort: 'பார்வதி',
      description: 'தக்கனின் சாபத்தால் தேய்ந்து மறைந்து கொண்டிருந்த சந்திரனுக்கு அபயமளித்து தனது சடைமுடியில் பிறையாகச் சூடியருளிய தயாபர மூர்த்தி.',
      speciality: 'சடாமகுடத்தில் பிறைச் சந்திரன், கங்கை, ஊமத்தம்பூ. மான், மழு ஏந்திய நான்கு திருக்கரங்கள், நின்ற கோலம்.',
    ),

    // 11. ரிஷபாரூட மூர்த்தி – Rishabharuda Murti
    const ShivaMurtiModel(
      id: 11,
      tamilName: 'ரிஷபாரூட மூர்த்தி',
      englishName: 'Rishabharuda Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வாகன திருக்கோலம் (Mounted on Nandi Bull)',
      defaultConsort: 'உமாதேவி',
      description: 'தர்மதேவதையான வெள்ளை நந்தி எம்பெருமான் மீது தேவியுடன் கம்பீரமாக எழுந்தருளி அருள்பாலிக்கும் திருமேனி.',
      speciality: 'நந்தியின் மீது அமர்ந்த திருக்கோலம். பிரதோஷ காலங்களிலும் பிரம்மோற்சவங்களிலும் பிரதான உற்சவ மூர்த்தியாக உலா வருதல்.',
    ),

    // 12. ரிஷபாந்திக மூர்த்தி – Rishabhantika Murti
    const ShivaMurtiModel(
      id: 12,
      tamilName: 'ரிஷபாந்திக மூர்த்தி',
      englishName: 'Rishabhantika Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சாந்த வடிவம் (Standing Beside the Bull)',
      defaultConsort: 'பார்வதி',
      description: 'தனது வாகனமான நந்தியின் தலைமீது வலது முழங்கையை மென்மையாக சாய்வாக வைத்து நின்ற திருக்கோலத்தில் அருள்புரியும் லலித மூர்த்தி.',
      speciality: 'நந்திக்கு அருகில் சாய்ந்த நிலையிலான கம்பீர நின்ற கோலம் (த்ரிபங்க வடிவம்).',
    ),

    // 13. புஜங்கலளித மூர்த்தி – Bhujangalalita Murti
    const ShivaMurtiModel(
      id: 13,
      tamilName: 'புஜங்கலளித மூர்த்தி',
      englishName: 'Bhujangalalita Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'விநோத யோக வடிவம் (Adorned with Serpents)',
      defaultConsort: 'பார்வதி',
      description: 'வாசுகி முதலான அஷ்டமகா நாகங்களை ஆபரணங்களாகவும் கங்கணமாகவும் அணிந்து லலிதமான நடனம் புரியும் வடிவம்.',
      speciality: 'நாகங்களை கரங்களிலும் மார்பிலும் ஆபரணமாகக் கொண்டு அடியவர்களின் சர்ப்ப தோஷங்களை நீக்கும் திருமேனி.',
    ),

    // 14. புஜங்கத்ராச மூர்த்தி – Bhujangatrasa Murti
    const ShivaMurtiModel(
      id: 14,
      tamilName: 'புஜங்கத்ராச மூர்த்தி',
      englishName: 'Bhujangatrasa Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர லீலா வடிவம் (Dispeller of Serpent Fear)',
      defaultConsort: 'பார்வதி',
      description: 'காலகூட விஷம் கக்கும் கொடிய நாகத்தை அநாயாசமாக மிதித்து அதன் அச்சத்தைப் போக்கி அடக்கியருளும் வீர நடன மூர்த்தி.',
      speciality: 'பாதத்தின் கீழே சுருண்ட பாம்பு, அச்சத்தை வென்ற அபய முத்திரை, வளைந்த நிருத்த பாதம்.',
    ),

    // 15. சந்த்யாநிருத்த மூர்த்தி – Sandhya Nritya Murti
    const ShivaMurtiModel(
      id: 15,
      tamilName: 'சந்த்யாநிருத்த மூர்த்தி',
      englishName: 'Sandhya Nritya Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'நிருத்த வடிவம் (Twilight Dance Form)',
      defaultConsort: 'உமாதேவி',
      description: 'பிரதோஷ அந்திவேளையில் முப்பத்து முக்கோடி தேவர்களும் கந்தர்வர்களும் இசைக்க, கைலாய மலையில் உமையவள் காண நிகழ்த்தும் ஆனந்த நடனம்.',
      speciality: 'சரஸ்வதி வீணை மீட்ட, பிரம்மா தாளம் போட, விஷ்ணு மத்தளம் முழங்க நிகழும் அந்தி நடனத் திருக்கோலம்.',
    ),

    // 16. சதாநிருத்த மூர்த்தி – Sada Nritya Murti
    const ShivaMurtiModel(
      id: 16,
      tamilName: 'சதாநிருத்த மூர்த்தி',
      englishName: 'Sada Nritya Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'நித்திய நடன வடிவம் (Eternal Dancing Nataraja)',
      defaultConsort: 'சிவகாமசுந்தரி',
      defaultRelationship: 'மனைவி (உடனுறை தேவி)',
      description: 'சிதம்பரப் பொன்னம்பலத்தில் இடைவிடாது ஆனந்தத் தாண்டவம் புரிந்து அண்ட சராசரங்களை இயக்கும் நடராஜப் பெருமானின் நித்திய திருநடனம்.',
      speciality: 'தூக்கிய திருவடி, உடுக்கை, அக்னி, அபயம், வரதம், முயலகன் மீது நின்ற கோலம், திருவாசியுடன் கூடிய ஆனந்த தாண்டவம்.',
    ),

    // 17. சண்டதாண்டவ மூர்த்தி – Chanda Tandava Murti
    const ShivaMurtiModel(
      id: 17,
      tamilName: 'சண்டதாண்டவ மூர்த்தி',
      englishName: 'Chanda Tandava Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ருத்ர நிருத்த வடிவம் (Fierce Cosmic Dance)',
      defaultConsort: 'காளி',
      description: 'அண்டங்களின் தீமைகளையும் இருளையும் அழித்து உலகங்களைச் சுத்திகரிக்கும் பிரளய கால உக்கிர ருத்ர தாண்டவத் திருமேனி.',
      speciality: 'பத்து அல்லது பதினாறு திருக்கரங்கள், உக்கிர ஆயுதங்கள், விரிந்த சடாமுடி, தீச்சுடர் திருவாசி.',
    ),

    // 18. கங்காதர மூர்த்தி – Gangadhara Murti
    const ShivaMurtiModel(
      id: 18,
      tamilName: 'கங்காதர மூர்த்தி',
      englishName: 'Gangadhara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அனுக்கிரக வடிவம் (Bearer of River Ganga)',
      defaultConsort: 'கங்காதேவி & பார்வதி',
      defaultRelationship: 'சிரசில் கங்கை, இடப்பாகத்தில் உமை',
      description: 'வானுலகிலிருந்து பெருவெள்ளமாகப் பாய்ந்து வந்த கங்கையின் கர்வத்தை அடக்கி தனது ஒற்றைச் சடைமுடியில் தாங்கி அருளிய மூர்த்தி.',
      speciality: 'வலது கரத்தால் சடையைப் பிரித்து கங்கையைத் தாங்கும் கோலம், இடப்புறம் ஊடல் கொண்ட பார்வதி தேவி.',
    ),

    // 19. கங்காவிசர்ஜன மூர்த்தி – Ganga Visarjana Murti
    const ShivaMurtiModel(
      id: 19,
      tamilName: 'கங்காவிசர்ஜன மூர்த்தி',
      englishName: 'Ganga Visarjana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'கிருபா வடிவம் (Releaser of River Ganga)',
      defaultConsort: 'கங்கை & பார்வதி',
      description: 'பகீரதனின் வேண்டுதலுக்கு இரங்கி, சடையில் அடக்கிய கங்கையை பூமிக்கு மெல்லிய நீரோட்டமாக விடுவித்து சாகரர்களுக்கு முக்தி தந்த மூர்த்தி.',
      speciality: 'சடையிலிருந்து விரல் வழியே துளியாக கங்கையை பூமிக்கு இறக்கும் கருணை ததும்பும் தோற்றம்.',
    ),

    // 20. திரிபுராந்தக மூர்த்தி – Tripurantaka Murti
    const ShivaMurtiModel(
      id: 20,
      tamilName: 'திரிபுராந்தக மூர்த்தி',
      englishName: 'Tripurantaka Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர சம்ஹார வடிவம் (Destroyer of Tripuras)',
      defaultConsort: 'பார்வதி',
      description: 'பூமியைத் தேராகவும், மேருவை வில்லாகவும், விஷ்ணுவை அம்பாகவும் பூட்டி பொன், வெள்ளி, இரும்பாலான அசுரர்களின் முப்புரங்களை நகைத்து எரித்த வீரமூர்த்தி.',
      speciality: 'வில்லம்பேந்திய வீரத் திருவுருவம், தேரில் நின்ற கோலம், மந்தகாசப் புன்னகையாலேயே முப்புரங்களை எரித்த தத்துவம்.',
    ),

    // 21. கல்யாணசுந்தர மூர்த்தி – Kalyanasundara Murti
    const ShivaMurtiModel(
      id: 21,
      tamilName: 'கல்யாணசுந்தர மூர்த்தி',
      englishName: 'Kalyanasundara Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (சிவ-சக்தி திருமண மங்கள வடிவம்)',
      formClassification: 'மங்கள திருமண வடிவம் (Divine Wedding Form)',
      defaultConsort: 'மீனாட்சி / பார்வதி தேவி',
      defaultRelationship: 'திருமண திருக்கோலம் (மணமகன் & மணமகள்)',
      description: 'பர்வதராஜன் மகளான உமாதேவியின் மலர்க்கரத்தைப் பற்றி மகாவிஷ்ணு தாரைவார்த்துக் கொடுக்க திருமணம் புரியும் சுந்தரேஸ்வரர் திருக்கோலம்.',
      speciality: 'வலது திருக்கரத்தால் பார்வதியின் திருக்கரம் பற்றும் பாணிக்கிரகண திருக்கோலம். சகல திருமண தோஷங்களையும் நீக்கும் அற்புத மூர்த்தி.',
    ),

    // 22. அர்த்தநாரீஸ்வர மூர்த்தி – Ardhanarishvara Murti
    const ShivaMurtiModel(
      id: 22,
      tamilName: 'அர்த்தநாரீஸ்வர மூர்த்தி',
      englishName: 'Ardhanarishvara Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (ஆண்-பெண் இணைவு / Composite Form)',
      formClassification: 'சங்கர / உபய வடிவம் (Half Shiva, Half Shakti)',
      defaultConsort: 'பார்வதி (இடப்பாகத்தில் ஐக்கியம்)',
      defaultRelationship: 'சிவனும் சக்தியும் ஒன்றான முழுமை',
      description: 'வலது பாகம் சிவபெருமானும் இடது பாகம் பார்வதி தேவியுமாக ஆணும் பெண்ணும் சமம் என்பதையும் சிவசக்தியின் பிரிக்க முடியாத ஒருமையையும் உணர்த்தும் அத்வைதத் திருமேனி.',
      speciality: 'வலப்பக்கம் ஜடாமுடி, திரிசூலம், புலித்தோல், கங்கை, நந்தி; இடப்பக்கம் கொண்டை, குங்குமம், வளையல், பட்டுச்சேலை, கிளி.',
    ),

    // 23. கஜயுத்த மூர்த்தி – Gajayuddha Murti
    const ShivaMurtiModel(
      id: 23,
      tamilName: 'கஜயுத்த மூர்த்தி',
      englishName: 'Gjayuddha Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர சம்ஹார வடிவம் (Battle with Gajhasura)',
      defaultConsort: 'பார்வதி',
      description: 'முனிவர்களை வதைக்க வந்த ஆணவமிக்க மதயானையான கஜாசுரனை வதம் செய்து அதன் தோலை உரித்துப் போர்த்திய கஜசம்ஹார வீர வடிவம்.',
      speciality: 'யானைத் தோலை இரு கரங்களால் விரித்துப் போர்த்தியவாறு ஒரு காலை யானையின் தலைமீது ஊன்றி நின்ற கம்பீர வீரக் கோலம்.',
    ),

    // 24. ஜ்வராபக்ன மூர்த்தி – Jvarabhagna Murti
    const ShivaMurtiModel(
      id: 24,
      tamilName: 'ஜ்வராபக்ன மூர்த்தி',
      englishName: 'Jvarabhagna Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'குணமளிக்கும் அருள் வடிவம் (Destroyer of Fevers)',
      defaultConsort: 'பார்வதி',
      description: 'மூன்று கால்கள், மூன்று முகங்கள், ஒன்பது கண்களுடன் அசுரர்களின் ஜுரங்களை அழித்து அடியார்களின் தீராத பிணிகளையும் நோய்களையும் தீர்க்கும் மூர்த்தி.',
      speciality: 'திரிபாதம் (3 கால்கள்), திரிமுகம் (3 முகங்கள்). சகலவிதமான காய்ச்சல், தொற்றுநோய்கள் மற்றும் மன உளைச்சல்களைத் தீர்க்கும் வைத்திய மூர்த்தி.',
    ),

    // 25. சார்த்தூலஹர மூர்த்தி – Shardulahara Murti
    const ShivaMurtiModel(
      id: 25,
      tamilName: 'சார்த்தூலஹர மூர்த்தி',
      englishName: 'Shardulahara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர சம்ஹார வடிவம் (Slayer of the Demon Tiger)',
      defaultConsort: 'பார்வதி',
      description: 'தாருகாவனத்து முனிவர்களின் கர்வம் ஏவிய ஆக்ரோஷப் புலியை வதம் செய்து அதன் தோலை ஆடையாக உடுத்திய வெற்றி வடிவம்.',
      speciality: 'புலித்தோல் ஆடை, புலியை அடக்கிய வீர பாவம். மனிதனின் புலனடக்கம் மற்றும் அகங்காரத்தை அடக்குவதை உணர்த்தும் வடிவம்.',
    ),

    // 26. பாசுபத மூர்த்தி – Pashupata Murti
    const ShivaMurtiModel(
      id: 26,
      tamilName: 'பாசுபத மூர்த்தி',
      englishName: 'Pashupata Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அஸ்திர அருள் வடிவம் (Bestower of Pashupatastra)',
      defaultConsort: 'பார்வதி',
      description: 'மகாபாரதப் போரில் வெற்றி பெற வேண்டி அர்ஜுனன் செய்த கடும் தவத்திற்கு உவந்து அவனுக்கு இணையற்ற பாசுபதாஸ்திரத்தை அருளிய மூர்த்தி.',
      speciality: 'பாசுபதாஸ்திரத்தை இரு திருக்கரங்களில் ஏந்தி வரமளிக்கும் கோலம். தீராத பகை, அச்சம், எதிர்ப்புகளை முறியடிக்கும் வடிவம்.',
    ),

    // 27. கங்காள மூர்த்தி – Kankala Murti
    const ShivaMurtiModel(
      id: 27,
      tamilName: 'கங்காள மூர்த்தி',
      englishName: 'Kankala Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வைராக்கிய உலா வடிவம் (Bearer of the Skeletal Staff)',
      defaultConsort: 'பார்வதி',
      description: 'பிரம்மனின் ஐந்தாவது தலையைக் கொய்த பாவத்தைப் போக்க விஷ்ணுவின் துவாரபாலகரான விஷ்வக்சேனரின் கங்காள எலும்பை தண்டத்தில் சுமந்து திரிந்த திருக்கோலம்.',
      speciality: 'தோளில் கங்காள தண்டம், கையில் தமருகம், சுற்றிலும் துள்ளி விளையாடும் மானும் பூதகணங்களும் பின்தொடர பவனி வரும் உலா வடிவம்.',
    ),

    // 28. கேசவார்த்த மூர்த்தி – Keshavartha Murti
    const ShivaMurtiModel(
      id: 28,
      tamilName: 'கேசவார்த்த மூர்த்தி',
      englishName: 'Keshavartha Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (சிவன்-விஷ்ணு இணைவு / Harihara)',
      formClassification: 'சங்கர / ஐக்கிய வடிவம் (Harihara - Half Shiva, Half Vishnu)',
      defaultConsort: 'உமாதேவி & லட்சுமி தேவி',
      defaultRelationship: 'ஹரியும் சிவனும் ஒன்றான திருமேனி',
      description: 'வலப்புறம் சடைமுடியும் பிறையும் மழுவும் ஏந்திய சிவனும், இடப்புறம் கிரீடமும் சங்கு சக்கரமும் ஏந்திய விஷ்ணுவுமாக திகழும் சங்கரநாராயண மூர்த்தி.',
      speciality: 'சைவ-வைணவ பேதமற்ற அத்வைத தத்துவம். வலதுபுறம் வெண்ணீறும் புலித்தோலும், இடதுபுறம் திருமண்ணும் பட்டுபீதாம்பரமும் மிளிரும் வடிவம்.',
    ),

    // 29. பிக்ஷாடன மூர்த்தி – Bhikshatana Murti
    const ShivaMurtiModel(
      id: 29,
      tamilName: 'பிக்ஷாடன மூர்த்தி',
      englishName: 'Bhikshatana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வைராக்கிய லீலா வடிவம் (Supreme Mendicant)',
      defaultConsort: 'பார்வதி',
      description: 'தாருகாவன முனிவர்களின் செருக்கையும் கர்ம ஆணவத்தையும் தகர்க்க பேரழகுப் பிச்சைக்காரனாக திகம்பர கோலத்தில் பிச்சையேற்க வந்த மோகன மூர்த்தி.',
      speciality: 'காலில் சிலம்பு, கையில் கபால ஓடு, மார்பில் பூணூல், புன்னகை பூத்த வதனம், அருகினில் துள்ளும் மான் மற்றும் மயங்கும் ரிஷிபத்தினிகள்.',
    ),

    // 30. சிம்ஹக்ன மூர்த்தி – Simhaghna Murti
    const ShivaMurtiModel(
      id: 30,
      tamilName: 'சிம்ஹக்ன மூர்த்தி',
      englishName: 'Simhaghna Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சரபேஸ்வர வீர வடிவம் (Subduer of Narasimha)',
      defaultConsort: 'பிரத்யங்கிரா & சூலினி துர்க்கை',
      defaultRelationship: 'சரபப் பறவையின் இரு இறக்கைகள்',
      description: 'இரணியனை வதம் செய்த நரசிம்மரின் உக்கிரத்தைத் தணித்து உலகை காக்க பறவை, விலங்கு, மனித அம்சங்கள் கொண்ட சரபப் பறவையாகத் தோன்றிய வடிவம்.',
      speciality: 'எட்டு கால்கள், இரு இறக்கைகள், பறவை மூக்கு, சிங்க உடல் கொண்ட சரபேஸ்வர மூர்த்தி. பில்லி, சூனியம், கொடிய நோய்களைப் போக்கும் காவல் வடிவம்.',
    ),

    // 31. சண்டேசானுக்ரஹ மூர்த்தி – Chandeshanugraha Murti
    const ShivaMurtiModel(
      id: 31,
      tamilName: 'சண்டேசானுக்ரஹ மூர்த்தி',
      englishName: 'Chandeshanugraha Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அனுக்கிரக வடிவம் (Blesser of Chandesha Nayanar)',
      defaultConsort: 'உமாதேவி',
      description: 'மணலால் சிவலிங்கம் செய்து பாலாபிஷேகம் செய்த விசாரசருமரின் பக்தியை மெச்சி தனது சடையில் உள்ள கொன்றை மாலையைச் சூட்டி சண்டேஸ்வர பதவி தந்த மூர்த்தி.',
      speciality: 'சண்டேசருக்கு தனது மாலையைச் சூட்டும் கருணைக் காட்சி. சிவபுண்ணியத்தின் பலனை அடியார்களுக்கு வழங்கும் பொறுப்பாளர்.',
    ),

    // 32. தட்சிணாமூர்த்தி – Dakshinamurti
    const ShivaMurtiModel(
      id: 32,
      tamilName: 'தட்சிணாமூர்த்தி',
      englishName: 'Dakshinamurti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ஞான குரு வடிவம் (Universal Teacher of Wisdom)',
      defaultConsort: '',
      defaultRelationship: 'ஞான தேசிகன் (ஜெகத்குரு)',
      description: 'கல்லால மரத்தடியில் தென்திசை நோக்கி வீற்றிருந்து சனகாதி முனிவர்கள் நால்வருக்கு வாய் திறவாமல் சின்முத்திரையால் மெய்ப்பொருளை உணர்த்திய ஞானகுரு.',
      speciality: 'வலது திருக்கரத்தில் ஞான முத்திரை (சின்முத்திரை), இடது கரத்தில் ஓலைச்சுவடி, காலடியில் அஞ்ஞான முயலகன், நான்கு சீடர்கள் சூழ அமர்ந்த திருக்கோலம்.',
    ),

    // 33. யோகதட்சிணாமூர்த்தி – Yoga Dakshinamurti
    const ShivaMurtiModel(
      id: 33,
      tamilName: 'யோகதட்சிணாமூர்த்தி',
      englishName: 'Yoga Dakshinamurti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'யோக தவ வடிவம் (Lord in Deep Yogic Trance)',
      defaultConsort: '',
      defaultRelationship: 'ஆதியோகி (முதல் யோகேஸ்வரர்)',
      description: 'யோக பட்டையுடன் உத்குடிகாசனத்தில் அமர்ந்து ஆத்ம ஞான சமாதியில் ஆழ்ந்திருக்கும் தட்சிணாமூர்த்தியின் யோக வடிவம்.',
      speciality: 'யோக பட்டை அணிந்த கால்கள், நாசி நுனியில் நிலைத்த கண்கள், குண்டலினி யோகத்தின் மூல அதிபதி.',
    ),

    // 34. வீணாதட்சிணாமூர்த்தி – Veena Dakshinamurti
    const ShivaMurtiModel(
      id: 34,
      tamilName: 'வீணாதட்சிணாமூர்த்தி',
      englishName: 'Veena Dakshinamurti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'நாத வித்யா வடிவம் (Master of Music and Veena)',
      defaultConsort: '',
      defaultRelationship: 'நாதப் பிரம்ம குரு',
      description: 'திருக்கரங்களில் வீணையை ஏந்தி நாதப் பிரம்மமாக இசைக்கலைக்கும் 64 கலைகளுக்கும் ஞானமளிக்கும் தட்சிணாமூர்த்தி வடிவம்.',
      speciality: 'வீணையை மீட்டும் இரு திருக்கரங்கள். கல்வி, இசை, நுண்கலைகளில் மேதைமை தரும் வடிவம்.',
    ),

    // 35. காலாந்தக மூர்த்தி – Kalantaka Murti
    const ShivaMurtiModel(
      id: 35,
      tamilName: 'காலாந்தக மூர்த்தி',
      englishName: 'Kalantaka Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார ரக்ஷக வடிவம் (Conqueror of Death)',
      defaultConsort: 'பார்வதி',
      description: 'பதினாறு வயதில் முடியும் மார்க்கண்டேயரின் உயிரைக் காக்க லிங்கத்திலிருந்து பிளந்து வெளிப்பட்டு எமனை எட்டி உதைத்த காலகால மூர்த்தி.',
      speciality: 'திருவடியால் காலனை வீழ்த்தி மார்க்கண்டேயருக்கு என்றும் பதினாறாய் வாழும் சிரஞ்சீவி வரம் தந்த திருக்கடையூர் அற்புத வடிவம்.',
    ),

    // 36. காமதஹன மூர்த்தி – Kamadahana Murti
    const ShivaMurtiModel(
      id: 36,
      tamilName: 'காமதஹன மூர்த்தி',
      englishName: 'Kamadahana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'யோக உக்கிர வடிவம் (Destroyer of Kamadeva)',
      defaultConsort: 'பார்வதி',
      description: 'யோகத் தவத்தைக் கலைக்க மலரம்புகளை எய்த மன்மதனை தனது நெற்றிக்கண் தீப்பொறியால் எரித்து சாம்பலாக்கி இச்சைகளை வென்ற தியாகமூர்த்தி.',
      speciality: 'திறந்த நெற்றிக்கண், சிற்றின்ப ஆசைகளை சாம்பலாக்கி ஆன்ம சுத்தியை அருளும் ஞானக் கோலம்.',
    ),

    // 37. லகுளீசுவர மூர்த்தி – Lakulishvara Murti
    const ShivaMurtiModel(
      id: 37,
      tamilName: 'லகுளீசுவர மூர்த்தி',
      englishName: 'Lakulishvara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'பாசுபத அவதார வடிவம் (Bearer of the Club)',
      defaultConsort: '',
      defaultRelationship: 'பாசுபத நெறி ஆசாரியர்',
      description: 'கையில் தண்டாயுதம் (லகுடம்) ஏந்தி பாசுபத சைவ நெறியை உலகிற்கு அருளிய அவதார குருமூர்த்தி.',
      speciality: 'கையில் கதாயுதம் போன்ற தண்டு, பத்மாசனம், யோக திருவுருவம்.',
    ),

    // 38. பைரவ மூர்த்தி – Bhairava Murti
    const ShivaMurtiModel(
      id: 38,
      tamilName: 'பைரவ மூர்த்தி',
      englishName: 'Bhairava Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர கால வடிவம் (Lord of Time and Protection)',
      defaultConsort: 'பைரவி',
      defaultRelationship: 'ஆலயக் காவல் தெய்வம்',
      description: 'நாய் வாகனத்துடன் திகழும் காலபைரவர். காலத்தின் அதிபதி; அடியார்களின் பயத்தை போக்கி ஆலயங்களையும் புண்ணிய பூமிகளையும் காப்பவர்.',
      speciality: 'திரிசூலம், உடுக்கை, பாசம், கபாலம் ஏந்திய நான்கு கரங்கள், நாய் வாகனம், பொன்வடம் மற்றும் பாம்பு ஆபரணங்கள்.',
    ),

    // 39. ஆபதோத்தாரண மூர்த்தி – Apaduddharana Murti
    const ShivaMurtiModel(
      id: 39,
      tamilName: 'ஆபதோத்தாரண மூர்த்தி',
      englishName: 'Apaduddharana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ரக்ஷக கருணை வடிவம் (Savior from Disasters)',
      defaultConsort: 'பார்வதி',
      description: 'அடியார்களுக்கு வரும் ஆபத்துகள், பேரிடர்கள், விஷபயங்கள், கிரக தோஷங்களை உடனே ஓடோடி வந்து காக்கும் கருணா பைரவர் வடிவம்.',
      speciality: 'சாந்த முகம், அபய-வரத கரங்கள், ஆபத்துகளில் இருந்து மீட்கும் சிறப்பு பிரார்த்தனை மூர்த்தி.',
    ),

    // 40. வடுக மூர்த்தி – Vatuka Murti
    const ShivaMurtiModel(
      id: 40,
      tamilName: 'வடுக மூர்த்தி',
      englishName: 'Vatuka Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'பால பிரம்மச்சாரி வடிவம் (Youthful Ascetic Bhairava)',
      defaultConsort: '',
      defaultRelationship: 'பால பைரவர்',
      description: 'பிரம்மச்சாரி பாலன் வடிவில் சாந்த சொரூபமாக அருள்பாலிக்கும் வடுக பைரவ மூர்த்தி.',
      speciality: 'இளம் சிறுவன் உருவம், கையில் கபாலம் மற்றும் சூலம், எளிதில் அடியார்களின் குறைகளைத் தீர்க்கும் வடிவம்.',
    ),

    // 41. சேத்திரபாலக மூர்த்தி – Kshetrapalaka Murti
    const ShivaMurtiModel(
      id: 41,
      tamilName: 'சேத்திரபாலக மூர்த்தி',
      englishName: 'Kshetrapalaka Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'காவல் வடிவம் (Guardian of Holy Shrines)',
      defaultConsort: '',
      defaultRelationship: 'ஆலயத் தலைமைப் பாதுகாவலர்',
      description: 'கோவில் திருத்தலங்களையும் புண்ணிய பூமிகளையும் இரவு பகலாக காத்து நிற்கும் காவல் தெய்வ மூர்த்தி.',
      speciality: 'கோவில் திறக்கும்போதும் அர்த்தஜாமத்தில் பூட்டும்போதும் முதல் மற்றும் இறுதி பூஜை பெறும் காவல் தலைவர்.',
    ),

    // 42. வீரபத்திர மூர்த்தி – Veerabhadra Murti
    const ShivaMurtiModel(
      id: 42,
      tamilName: 'வீரபத்திர மூர்த்தி',
      englishName: 'Veerabhadra Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ரௌத்ர வீர வடிவம் (Fierce Heroic Manifestation)',
      defaultConsort: 'பத்ரகாளி',
      defaultRelationship: 'மனைவி (உடனுறை தேவி)',
      description: 'தட்சனின் யாகத்தை அழிக்கவும் நீதியை நிலைநாட்டவும் சிவனின் சடாமுடியிலிருந்து அக்னிப் பிழம்பாய் தோன்றிய வீர மூர்த்தி.',
      speciality: 'வாள், கேடயம், வில், அம்பு ஏந்திய திருக்கரங்கள், உக்கிர நேத்திரம், தட்சனை மன்னித்து ஆட்டுத் தலை வைத்து அருளிய வடிவம்.',
    ),

    // 43. அகோராஸ்திர மூர்த்தி – Aghorastra Murti
    const ShivaMurtiModel(
      id: 43,
      tamilName: 'அகோராஸ்திர மூர்த்தி',
      englishName: 'Aghorastra Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அஸ்திர உக்கிர வடிவம் (Embodiment of Aghorastra)',
      defaultConsort: '',
      defaultRelationship: 'பரமசிவனின் திவ்ய அஸ்திரம்',
      description: 'அசுரர்களை அழிக்கவும் தீமைகளை விரட்டவும் ஈசனால் ஏவப்பட்ட இணையற்ற அகோர அஸ்திரத்தின் உருவமயமான திருமேனி.',
      speciality: 'பல்வேறு ஆயுதங்களுடன் சுடர்விட்டு எரியும் அக்னி சுவாலை வடிவம். திருவெண்காட்டில் வழிபடப்படும் சிறப்பு மூர்த்தி.',
    ),

    // 44. தக்ஷயஜ்ஞஹர மூர்த்தி – Dakshayajnahara Murti
    const ShivaMurtiModel(
      id: 44,
      tamilName: 'தக்ஷயஜ்ஞஹர மூர்த்தி',
      englishName: 'Dakshayajnahara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார நீதி வடிவம் (Destroyer of Daksha Sacrifice)',
      defaultConsort: 'சதி தேவி / பார்வதி',
      description: 'சிவநிந்தனை செய்த தட்சனின் செருக்கை அழித்து அவனது யாகத்தை தரைமட்டமாக்கி அதர்மத்தை வேரறுத்த நீதியின் வடிவம்.',
      speciality: 'யாகசாலை அழிப்பு, தேவர்களின் அகந்தையை அடக்கி பிராயச்சித்தம் அருளிய கம்பீரத் தோற்றம்.',
    ),

    // 45. கிராத மூர்த்தி – Kirata Murti
    const ShivaMurtiModel(
      id: 45,
      tamilName: 'கிராத மூர்த்தி',
      englishName: 'Kirata Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'லீலா வேடன் வடிவம் (Divine Hunter Form)',
      defaultConsort: 'கிராத ரூபிணி (பார்வதி)',
      defaultRelationship: 'வேடுவ வடிவில் சிவசக்தி',
      description: 'அர்ஜுனனின் வில்லாற்றலை சோதித்து அவனுக்கு அருள காட்டில் பார்வதியுடன் வேடன் உருவம் தாங்கி வந்த பரமசிவன்.',
      speciality: 'வில் அம்பு ஏந்திய வேடுவத் தோற்றம், பன்றியை நோக்கி அம்பு எய்தல், அர்ஜுனனுடன் வில் யுத்தம் புரிந்து பாசுபதம் வழங்கிய வடிவம்.',
    ),

    // 46. குருமூர்த்தி – Guru Murti
    const ShivaMurtiModel(
      id: 46,
      tamilName: 'குருமூர்த்தி',
      englishName: 'Guru Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ஆசாரிய ஞான வடிவம் (Universal Spiritual Master)',
      defaultConsort: '',
      defaultRelationship: 'சற்குருநாதர்',
      description: 'மாணிக்கவாசகர் முதலான மெய்யன்பர்களுக்கு திருப்பெருந்துறையில் குருந்த மரத்தடியில் ஆசாரியனாக எழுந்தருளி உபதேசம் செய்த வடிவம்.',
      speciality: 'ஞான ஆடை, துறவுக் கோலம், சிவஞான போதம் அருளும் குருநாதர்.',
    ),

    // 47. அசுவாரூட மூர்த்தி – Ashvarudha Murti
    const ShivaMurtiModel(
      id: 47,
      tamilName: 'அசுவாரூட மூர்த்தி',
      englishName: 'Ashvarudha Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'லீலா குதிரை வீரன் வடிவம் (Rider of the Divine Steed)',
      defaultConsort: 'மீனாட்சி',
      description: 'மாணிக்கவாசகருக்காக காட்டின் நரிகளை பரிகளாக்கி (குதிரைகள்) தானே தலைமைக் குதிரைச் சேவகனாக மதுரைக்கு எழுந்தருளிய திருவிளையாடல் வடிவம்.',
      speciality: 'குதிரை மீது கம்பீரமாக சவாரி செய்யும் திருவுருவம், கையில் குதிரைச் சவுக்கு, ராஜ அலங்காரம்.',
    ),

    // 48. கஜாந்திக மூர்த்தி – Gajantika Murti
    const ShivaMurtiModel(
      id: 48,
      tamilName: 'கஜாந்திக மூர்த்தி',
      englishName: 'Gajantika Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சாந்த அருள் வடிவம் (Lord Beside the Elephant)',
      defaultConsort: 'பார்வதி',
      description: 'ஐராவதம் முதலான தேவயானைகளின் சாபத்தை நீக்கி அருள்புரிந்த சாந்த மூர்த்தி.',
      speciality: 'யானைக்கு அருகில் நின்று அதன் தலையைத் தொட்டு அருளும் வாஞ்சை வடிவம்.',
    ),

    // 49. ஜலந்தரவத மூர்த்தி – Jalandharavadha Murti
    const ShivaMurtiModel(
      id: 49,
      tamilName: 'ஜலந்தரவத மூர்த்தி',
      englishName: 'Jalandharavadha Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வீர சம்ஹார வடிவம் (Slayer of Demon Jalandhara)',
      defaultConsort: 'பார்வதி',
      description: 'கடலில் தோன்றி கர்வம் கொண்ட கொடுங்கோலன் ஜலந்தராசுரனைத் தன் கால் விரலால் தரையில் வரைந்த சக்கரத்தைக் கொண்டு வதம் செய்த மூர்த்தி.',
      speciality: 'கால் விரலால் வரைந்த சுதர்சன சக்கரத்தை ஏந்திய வடிவம், அசுரர்களை அழிக்கும் நீதித் தோற்றம்.',
    ),

    // 50. ஏகபாதத்ரி மூர்த்தி – Ekapada Trimurti
    const ShivaMurtiModel(
      id: 50,
      tamilName: 'ஏகபாதத்ரி மூர்த்தி',
      englishName: 'Ekapada Trimurti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (மும்மூர்த்தி இணைவு / Composite)',
      formClassification: 'சங்கர பரம்பொருள் வடிவம் (Single-Footed Supreme Trinity)',
      defaultConsort: 'சரஸ்வதி, உமை, லட்சுமி',
      defaultRelationship: 'மும்மூர்த்திகளின் மூல வடிவம்',
      description: 'ஒரே ஒரு திருப்பாதத்தில் நிற்க, நடுவில் சிவனும், வலப்புறம் பிரம்மனும், இடப்புறம் விஷ்ணுவும் தோன்றி சிவனே ஆதிமூலம் என்பதை உணர்த்தும் அரிய மூர்த்தி.',
      speciality: 'ஒற்றைப் பாதம், உடலின் பக்கவாட்டில் பிரம்மனும் விஷ்ணுவும் கைகூப்பித் தொழும் ஆச்சரியமான வடிவமைப்பு.',
    ),

    // 51. திரிபாதத்ரி மூர்த்தி – Tripada Trimurti
    const ShivaMurtiModel(
      id: 51,
      tamilName: 'திரிபாதத்ரி மூர்த்தி',
      englishName: 'Tripada Trimurti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (மும்மூர்த்தி தத்துவ வடிவம்)',
      formClassification: 'விஸ்வரூப வடிவம் (Three-Footed Trinity Form)',
      defaultConsort: 'முப்பெருந்தேவியர்',
      description: 'மூன்று திருப்பாதங்களுடன் பிரம்மா, விஷ்ணு, ருத்ரன் ஆகிய முத்தொழில் தலைவர்களையும் தன்னுள் அடக்கிய முழுமுதற் பரம்பொருள்.',
      speciality: 'மூன்று கால்கள், ஆறு கரங்கள், படைத்தல், காத்தல், அழித்தல் ஆகிய முத்தத்துவங்களின் ஒருங்கிணைந்த தரிசனம்.',
    ),

    // 52. ஏகபாத மூர்த்தி – Ekapada Murti
    const ShivaMurtiModel(
      id: 52,
      tamilName: 'ஏகபாத மூர்த்தி',
      englishName: 'Ekapada Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ஏக தத்துவ வடிவம் (The Single-Footed Lord)',
      defaultConsort: '',
      defaultRelationship: 'ஏக பரம்பொருள்',
      description: 'ஒரே ஒரு காலில் நின்று அண்ட சராசரங்களையும் தாங்கி நிற்கும் தியான நிலை மூர்த்தி.',
      speciality: 'ஒற்றைக் கால் தவம், நிலைபெற்ற ஞானம் மற்றும் உறுதிக்கு வழிகாட்டும் வடிவம்.',
    ),

    // 53. கௌரீவரப்ரத மூர்த்தி – Gaurivaraprada Murti
    const ShivaMurtiModel(
      id: 53,
      tamilName: 'கௌரீவரப்ரத மூர்த்தி',
      englishName: 'Gaurivaraprada Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (கௌரிக்கு வரமளித்த தெய்வம்)',
      formClassification: 'அனுக்கிரக போக வடிவம் (Bestower of Boons to Gauri)',
      defaultConsort: 'கௌரி (பார்வதி)',
      defaultRelationship: 'மனைவி (வரம்பெற்ற தேவி)',
      description: 'பார்வதி தேவி கடும் தவம் செய்து தன் இடப்பாகத்தைப் பெற விரும்பியபோது மகிழ்ந்து சகல வரங்களையும் நல்கிய மூர்த்தி.',
      speciality: 'வரத முத்திரையுடன் பார்வதி தேவிக்கு தன் திருமேனியில் இடப்பாகம் அளித்து ஆசீர்வதிக்கும் கோலம்.',
    ),

    // 54. சக்ரதானஸ்வரூப மூர்த்தி – Chakradana Murti
    const ShivaMurtiModel(
      id: 54,
      tamilName: 'சக்ரதானஸ்வரூப மூர்த்தி',
      englishName: 'Chakradana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அனுக்கிரக வடிவம் (Bestower of Sudarshana Chakra)',
      defaultConsort: 'பார்வதி',
      description: 'தினமும் ஆயிரம் தாமரை மலர்களால் அர்ச்சித்த மகாவிஷ்ணுவிற்கு, ஒரு தாமரை குறைந்தபோது தன் கண்ணையே பெயர்த்து அர்ச்சித்த பக்திக்கு மெச்சி சுதர்சன சக்கரத்தை வழங்கிய மூர்த்தி.',
      speciality: 'திருக்கரத்தில் சுதர்சன சக்கரம் ஏந்தி விஷ்ணுவிற்கு அருளும் காட்சி. திருவீழிமிழலை முதலான தலங்களின் பிரதான வடிவம்.',
    ),

    // 55. கௌரிலீலாசமன்வித மூர்த்தி – Gaurililasamanvita Murti
    const ShivaMurtiModel(
      id: 55,
      tamilName: 'கௌரிலீலாசமன்வித மூர்த்தி',
      englishName: 'Gaurililasamanvita Murti',
      genderClassification: 'other',
      genderLabelTamil: 'மற்றவை (தேவியுடன் திருவிளையாடல் புரிந்த மூர்த்தி)',
      formClassification: 'லீலா ஆனந்த வடிவம் (Lord in Play with Gauri)',
      defaultConsort: 'கௌரி (பார்வதி)',
      defaultRelationship: 'மனைவி (திருவிளையாடல் துணைவி)',
      description: 'உமாதேவியுடன் சொக்கட்டான் முதலான திருவிளையாடல்கள் புரிந்து அண்டங்களின் இயக்கத்தை உல்லாசமாக நடத்தும் இனிய வடிவம்.',
      speciality: 'ஈசனும் தேவியும் மகிழ்வோடு அமர்ந்து விளையாடும் லீலா தரிசனம். குடும்ப மகிழ்ச்சியையும் இல்லற அமைதியையும் நல்கும் மூர்த்தி.',
    ),

    // 56. விஷாபஹரண மூர்த்தி – Vishapaharana Murti
    const ShivaMurtiModel(
      id: 56,
      tamilName: 'விஷாபஹரண மூர்த்தி',
      englishName: 'Vishapaharana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'ரக்ஷக தியாக வடிவம் (Drinker of Halahala Poison)',
      defaultConsort: 'பார்வதி (கழுத்தைத் தொட்டு நஞ்சை நிறுத்தியவள்)',
      defaultRelationship: 'நீலகண்ட பரமேஸ்வரர்',
      description: 'பாற்கடலில் பொங்கிய கொடிய ஆலகால நஞ்சை உலக உயிர்களைக் காக்க தாமே விரும்பி உண்டு தன் கண்டத்தில் நிறுத்தி நீலகண்டனான தியாகமூர்த்தி.',
      speciality: 'நீல நிறக் கழுத்து, கையில் நச்சுக் கிண்ணம், அடியார்களின் அனைத்து நச்சுத் துன்பங்களையும் நோய்களையும் போக்கும் கருணை வடிவம்.',
    ),

    // 57. கருடாந்திக மூர்த்தி – Garudantika Murti
    const ShivaMurtiModel(
      id: 57,
      tamilName: 'கருடாந்திக மூர்த்தி',
      englishName: 'Garudantika Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அனுக்கிரக வடிவம் (Blesser of Garuda)',
      defaultConsort: 'பார்வதி',
      description: 'கருட பகவானின் கர்வத்தை அகற்றி அவனுக்கு தனது பாம்புகளோடு சமாதானமும் இறையருளும் பாலித்த கருணாமூர்த்தி.',
      speciality: 'கருடன் கைகூப்பி அடிபணிந்து நிற்க, அவனுக்கு வரம் தரும் சாந்தக் கோலம்.',
    ),

    // 58. பிரம்மசிரச்சேத மூர்த்தி – Brahmashirachheda Murti
    const ShivaMurtiModel(
      id: 58,
      tamilName: 'பிரம்மசிரச்சேத மூர்த்தி',
      englishName: 'Brahmashirachheda Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார நீதி வடிவம் (Severer of Brahma Fifth Head)',
      defaultConsort: 'பார்வதி',
      description: 'ஐந்து தலைகளால் ஆணவம் கொண்டு தர்மம் தவறிய பிரம்மனின் ஐந்தாவது தலையைக் கிள்ளி அகந்தையை அடக்கிய நீதி வடிவம்.',
      speciality: 'கையில் பிரம்ம கபாலம் ஏந்திய பைரவத் திருக்கோலம். ஆணவ மலத்தை வேரறுக்கும் ஞான வடிவம்.',
    ),

    // 59. கூர்மசம்ஹார மூர்த்தி – Kurmasamhara Murti
    const ShivaMurtiModel(
      id: 59,
      tamilName: 'கூர்மசம்ஹார மூர்த்தி',
      englishName: 'Kurmasamhara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார வீர வடிவம் (Subduer of the Cosmic Tortoise)',
      defaultConsort: 'பார்வதி',
      description: 'பிரளயத்தில் கடல் கொதித்தெழ காரணமான பெருங்கூர்மத்தின் கொதிப்பைத் தணித்து அதன் ஓட்டினை தன் மார்பில் மாலையாக அணிந்த மூர்த்தி.',
      speciality: 'மார்பில் ஆமை ஓடு மாலையாக அணிந்த தோற்றம். உலகப் பிரளயத்தை அடக்கும் பேராற்றலின் வடிவம்.',
    ),

    // 60. மச்சசம்ஹார மூர்த்தி – Matsyasamhara Murti
    const ShivaMurtiModel(
      id: 60,
      tamilName: 'மச்சசம்ஹார மூர்த்தி',
      englishName: 'Matsyasamhara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார வீர வடிவம் (Subduer of the Cosmic Fish)',
      defaultConsort: 'பார்வதி',
      description: 'சமுத்திரத்தைக் கலக்கி உலகிற்கு அச்சுறுத்தலான மச்சத்தின் கண்ணைப் பிடுங்கி சாந்தப்படுத்தி அதன் தோலை அணிந்த வீரத் திருக்கோலம்.',
      speciality: 'மச்சத்தை அடக்கி கடலை சாந்தப்படுத்திய கம்பீர வடிவம்.',
    ),

    // 61. வராகசம்ஹார மூர்த்தி – Varahasamhara Murti
    const ShivaMurtiModel(
      id: 61,
      tamilName: 'வராகசம்ஹார மூர்த்தி',
      englishName: 'Varahasamhara Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'சம்ஹார வீர வடிவம் (Subduer of the Cosmic Boar)',
      defaultConsort: 'பார்வதி',
      description: 'பாதாளம் வரை சென்று பூமியைக் குடைந்து கர்வம் கொண்ட வராகத்தின் கொம்பை ஒடித்து தன் மார்பில் ஆபரணமாக அணிந்த வடிவம்.',
      speciality: 'வராகக் கொம்பை மார்பில் அணிந்த திருக்கோலம். அசுர வலிமையையும் மாயையையும் அடக்கும் ஆற்றல்.',
    ),

    // 62. பிரார்த்தனா மூர்த்தி – Prarthana Murti
    const ShivaMurtiModel(
      id: 62,
      tamilName: 'பிரார்த்தனா மூர்த்தி',
      englishName: 'Prarthana Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'அனுக்கிரக வடிவம் (Lord Answering Prayers)',
      defaultConsort: 'பார்வதி',
      description: 'தேவர்களும் முனிவர்களும் மனிதர்களும் கைகூப்பித் தொழும்போது அவர்களது உளமார்ந்த பிரார்த்தனைகளை உடனே நிறைவேற்றித் தரும் மூர்த்தி.',
      speciality: 'இரு திருக்கரங்களும் அபய-வரத முத்திரைகளுடன் பக்தர்களின் வேண்டுதல்களைக் கேட்கும் இன்முகப் பிரசன்ன வடிவம்.',
    ),

    // 63. ரத்தபிக்ஷாப்ரதான மூர்த்தி – Raktabhikshaprada Murti
    const ShivaMurtiModel(
      id: 63,
      tamilName: 'ரத்தபிக்ஷாப்ரதான மூர்த்தி',
      englishName: 'Raktabhikshaprada Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'உக்கிர சம்ஹார வடிவம் (Bestower of Blood Alms)',
      defaultConsort: 'பார்வதி',
      description: 'வாமன திரிவிக்ரம அவதாரத்தின் முடிவில் உண்டான உக்கிரத்தைத் தணிக்க, அதன் குருதியை கபாலத்தில் ஏற்று சாந்தப்படுத்திய மூர்த்தி.',
      speciality: 'கபாலத்தில் உதிரமேற்று உலகை சாந்தப்படுத்திய வைராக்கிய கோலம்.',
    ),

    // 64. சிஷ்யபாவ மூர்த்தி – Shishyabhava Murti
    const ShivaMurtiModel(
      id: 64,
      tamilName: 'சிஷ்யபாவ மூர்த்தி',
      englishName: 'Shishyabhava Murti',
      genderClassification: 'male',
      genderLabelTamil: 'ஆண் தெய்வம்',
      formClassification: 'வினய ஞான வடிவம் (Lord as Student to Swaminatha)',
      defaultConsort: 'பார்வதி',
      defaultRelationship: 'முருகப்பெருமானின் தந்தை & சீடர்',
      description: 'சுவாமிமலையில் தனது மைந்தன் முருகப் பெருமானிடம் சீடனைப் போல பணிவோடு கை கட்டி வாய் பொத்தி அமர்ந்து பிரணவ மந்திரத்தின் மூலப் பொருளைக் கேட்டறிந்த தகைசால் மூர்த்தி.',
      speciality: 'மகன் குருவாக அமர, தந்தை சீடனாக கை கூப்பி உபதேசம் கேட்கும் பாவம். ஆணவமற்ற உண்மையான ஞானப் பணிவின் உச்சகட்ட வடிவம்.',
    ),
  ];

  static List<ShivaMurtiModel> getActiveMurtis() {
    return all64Murtis.where((m) => m.isActive).toList();
  }

  static List<ShivaMurtiModel> filterByGender(String gender) {
    if (gender.isEmpty || gender == 'all') return all64Murtis;
    final lower = gender.toLowerCase();
    if (lower.contains('ஆண்') || lower == 'male') {
      return all64Murtis.where((m) => m.genderClassification == 'male').toList();
    } else if (lower.contains('பெண்') || lower == 'female') {
      return all64Murtis.where((m) => m.genderClassification == 'female').toList();
    } else if (lower.contains('மற்றவை') || lower == 'other' || lower == 'composite') {
      return all64Murtis.where((m) => m.genderClassification == 'other' || m.genderClassification == 'composite').toList();
    }
    return all64Murtis;
  }

  static List<ShivaMurtiModel> search(String query, {String? genderFilter}) {
    List<ShivaMurtiModel> list = (genderFilter != null && genderFilter != 'all')
        ? filterByGender(genderFilter)
        : all64Murtis;

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return list;

    // Search by ID, Tamil name, English name, or form classification
    return list.where((m) {
      final idMatch = m.id.toString() == trimmed;
      final tamilMatch = m.tamilName.toLowerCase().contains(trimmed);
      final englishMatch = m.englishName.toLowerCase().contains(trimmed);
      final formMatch = m.formClassification.toLowerCase().contains(trimmed);
      return idMatch || tamilMatch || englishMatch || formMatch;
    }).toList();
  }

  static ShivaMurtiModel? findById(int id) {
    try {
      return all64Murtis.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static ShivaMurtiModel? findByName(String name) {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    try {
      return all64Murtis.firstWhere((m) =>
          m.tamilName.toLowerCase() == trimmed ||
          m.englishName.toLowerCase() == trimmed ||
          '${m.tamilName} – ${m.englishName}'.toLowerCase() == trimmed ||
          '${m.tamilName} (${m.englishName})'.toLowerCase() == trimmed ||
          m.displayName.toLowerCase() == trimmed);
    } catch (_) {
      return null;
    }
  }
}
