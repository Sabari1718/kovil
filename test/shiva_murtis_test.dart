import 'package:flutter_test/flutter_test.dart';
import 'package:kulatheivam/features/deities/data/shiva_murtis_data.dart';

void main() {
  group('64 Shiva Murtis Master Data Verification', () {
    test('1 & 2. Verify all 64 Shiva Murti records exist and total count is 64', () {
      final list = ShivaMurtisMasterData.all64Murtis;
      expect(list.length, equals(64), reason: 'Total records must be exactly 64');
      expect(ShivaMurtisMasterData.getActiveMurtis().length, equals(64));
    });

    test('3 & 4. Verify No missing names and No duplicate IDs or Names', () {
      final list = ShivaMurtisMasterData.all64Murtis;
      final ids = <int>{};
      final tamilNames = <String>{};
      final englishNames = <String>{};

      for (int i = 0; i < list.length; i++) {
        final murti = list[i];
        // Sequential ID 1..64
        expect(murti.id, equals(i + 1), reason: 'ID must match index + 1');
        expect(ids.contains(murti.id), isFalse, reason: 'Duplicate ID: ${murti.id}');
        ids.add(murti.id);

        // Non-empty names
        expect(murti.tamilName.trim().isNotEmpty, isTrue, reason: 'Tamil name cannot be empty for ID ${murti.id}');
        expect(murti.englishName.trim().isNotEmpty, isTrue, reason: 'English name cannot be empty for ID ${murti.id}');

        // Uniqueness
        expect(tamilNames.contains(murti.tamilName), isFalse, reason: 'Duplicate Tamil name: ${murti.tamilName}');
        expect(englishNames.contains(murti.englishName), isFalse, reason: 'Duplicate English name: ${murti.englishName}');
        tamilNames.add(murti.tamilName);
        englishNames.add(murti.englishName);

        // Required master fields
        expect(murti.description.trim().isNotEmpty, isTrue);
        expect(murti.speciality.trim().isNotEmpty, isTrue);
        expect(murti.referenceSource.trim().isNotEmpty, isTrue);
        expect(murti.formClassification.trim().isNotEmpty, isTrue);
        expect(murti.image.trim().isNotEmpty, isTrue);
      }

      expect(ids.length, equals(64));
      expect(tamilNames.length, equals(64));
      expect(englishNames.length, equals(64));
    });

    test('5. Verify exact 64 names match canonical user requirements', () {
      final expectedNames = [
        'இலிங்க மூர்த்தி',
        'இலிங்கோற்பவ மூர்த்தி',
        'முகலிங்க மூர்த்தி',
        'சதாசிவ மூர்த்தி',
        'மகாசதாசிவ மூர்த்தி',
        'உமாமகேச மூர்த்தி',
        'சுகாசன மூர்த்தி',
        'உமேச மூர்த்தி',
        'சோமாஸ்கந்த மூர்த்தி',
        'சந்திரசேகர மூர்த்தி',
        'ரிஷபாரூட மூர்த்தி',
        'ரிஷபாந்திக மூர்த்தி',
        'புஜங்கலளித மூர்த்தி',
        'புஜங்கத்ராச மூர்த்தி',
        'சந்த்யாநிருத்த மூர்த்தி',
        'சதாநிருத்த மூர்த்தி',
        'சண்டதாண்டவ மூர்த்தி',
        'கங்காதர மூர்த்தி',
        'கங்காவிசர்ஜன மூர்த்தி',
        'திரிபுராந்தக மூர்த்தி',
        'கல்யாணசுந்தர மூர்த்தி',
        'அர்த்தநாரீஸ்வர மூர்த்தி',
        'கஜயுத்த மூர்த்தி',
        'ஜ்வராபக்ன மூர்த்தி',
        'சார்த்தூலஹர மூர்த்தி',
        'பாசுபத மூர்த்தி',
        'கங்காள மூர்த்தி',
        'கேசவார்த்த மூர்த்தி',
        'பிக்ஷாடன மூர்த்தி',
        'சிம்ஹக்ன மூர்த்தி',
        'சண்டேசானுக்ரஹ மூர்த்தி',
        'தட்சிணாமூர்த்தி',
        'யோகதட்சிணாமூர்த்தி',
        'வீணாதட்சிணாமூர்த்தி',
        'காலாந்தக மூர்த்தி',
        'காமதஹன மூர்த்தி',
        'லகுளீசுவர மூர்த்தி',
        'பைரவ மூர்த்தி',
        'ஆபதோத்தாரண மூர்த்தி',
        'வடுக மூர்த்தி',
        'சேத்திரபாலக மூர்த்தி',
        'வீரபத்திர மூர்த்தி',
        'அகோராஸ்திர மூர்த்தி',
        'தக்ஷயஜ்ஞஹர மூர்த்தி',
        'கிராத மூர்த்தி',
        'குருமூர்த்தி',
        'அசுவாரூட மூர்த்தி',
        'கஜாந்திக மூர்த்தி',
        'ஜலந்தரவத மூர்த்தி',
        'ஏகபாதத்ரி மூர்த்தி',
        'திரிபாதத்ரி மூர்த்தி',
        'ஏகபாத மூர்த்தி',
        'கௌரீவரப்ரத மூர்த்தி',
        'சக்ரதானஸ்வரூப மூர்த்தி',
        'கௌரிலீலாசமன்வித மூர்த்தி',
        'விஷாபஹரண மூர்த்தி',
        'கருடாந்திக மூர்த்தி',
        'பிரம்மசிரச்சேத மூர்த்தி',
        'கூர்மசம்ஹார மூர்த்தி',
        'மச்சசம்ஹார மூர்த்தி',
        'வராகசம்ஹார மூர்த்தி',
        'பிரார்த்தனா மூர்த்தி',
        'ரத்தபிக்ஷாப்ரதான மூர்த்தி',
        'சிஷ்யபாவ மூர்த்தி',
      ];

      for (int i = 0; i < expectedNames.length; i++) {
        expect(ShivaMurtisMasterData.all64Murtis[i].tamilName, equals(expectedNames[i]));
      }
    });

    test('6. Verify Gender classification & composite forms are properly handled', () {
      final maleList = ShivaMurtisMasterData.filterByGender('male');
      final otherList = ShivaMurtisMasterData.filterByGender('other');

      // Ardhanarishvara (ID 22) must be composite / other
      final ardhanarishvara = ShivaMurtisMasterData.findById(22);
      expect(ardhanarishvara, isNotNull);
      expect(ardhanarishvara!.genderClassification, equals('other'));
      expect(ardhanarishvara.genderLabelTamil, contains('ஆண்-பெண் இணைவு'));

      // Keshavartha (ID 28) must be composite / other
      final keshavartha = ShivaMurtisMasterData.findById(28);
      expect(keshavartha, isNotNull);
      expect(keshavartha!.genderClassification, equals('other'));

      // Ekapada Trimurti (50) and Tripada Trimurti (51)
      expect(ShivaMurtisMasterData.findById(50)!.genderClassification, equals('other'));
      expect(ShivaMurtisMasterData.findById(51)!.genderClassification, equals('other'));

      // Total count across male and other should cover all 64
      expect(maleList.length + otherList.length, equals(64));
      expect(maleList.length, equals(54));
      expect(otherList.length, equals(10));

      // Gender filter 'all' must return all 64
      expect(ShivaMurtisMasterData.filterByGender('all').length, equals(64));
    });

    test('7. Verify Search functionality', () {
      // Search by Tamil
      final natarajaResults = ShivaMurtisMasterData.search('நடராஜ' /* or நிருத்த */);
      expect(ShivaMurtisMasterData.search('நிருத்த').length, greaterThanOrEqualTo(2));
      expect(ShivaMurtisMasterData.search('அர்த்தநாரீஸ்வர').length, equals(1));

      // Search by English
      final dakshinamurti = ShivaMurtisMasterData.search('Dakshinamurti');
      expect(dakshinamurti.length, equals(3)); // Dakshinamurti, Yoga Dakshinamurti, Veena Dakshinamurti

      // Search by ID
      final id22 = ShivaMurtisMasterData.search('22');
      expect(id22.any((m) => m.id == 22), isTrue);

      // Search with gender filter
      final maleSearch = ShivaMurtisMasterData.search('', genderFilter: 'male');
      expect(maleSearch.length, equals(54));
      final otherSearch = ShivaMurtisMasterData.search('', genderFilter: 'other');
      expect(otherSearch.length, equals(10));
    });

    test('8. Verify Model JSON serialization and deserialization', () {
      final linga = ShivaMurtisMasterData.findById(1)!;
      final json = linga.toJson();
      expect(json['tamil_name'], equals('இலிங்க மூர்த்தி'));
      expect(json['english_name'], equals('Linga Murti'));

      final fromJson = ShivaMurtiModel.fromJson(json);
      expect(fromJson.id, equals(1));
      expect(fromJson.tamilName, equals('இலிங்க மூர்த்தி'));
      expect(fromJson.englishName, equals('Linga Murti'));
      expect(fromJson.genderClassification, equals('male'));
    });
  });
}
