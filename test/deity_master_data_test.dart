import 'package:flutter_test/flutter_test.dart';
import 'package:kulatheivam/features/deities/data/deity_master_data.dart';

void main() {
  group('1. Primary Deity Categories Master Data Tests', () {
    test('Categories must include independent Vishnu, Murugan, and Vinayagar', () {
      expect(VishnuMasterData.categoryName, equals('விஷ்ணு'));
      expect(VishnuMasterData.categoryNameEn, equals('Vishnu'));

      expect(MuruganMasterData.categoryName, equals('முருகன்'));
      expect(MuruganMasterData.categoryNameEn, equals('Murugan'));

      expect(VinayagarMasterData.categoryName, equals('விநாயகர்'));
      expect(VinayagarMasterData.categoryNameEn, equals('Vinayagar'));

      // Ensure Murugan and Vinayagar are distinct and not nested under Shiva
      expect(MuruganMasterData.categoryName, isNot(equals('சிவன்')));
      expect(VinayagarMasterData.categoryName, isNot(equals('சிவன்')));
    });
  });

  group('2. Vishnu Master Data Verification', () {
    test('Default Gender and Relationship', () {
      expect(VishnuMasterData.defaultGender, equals('ஆண் தெய்வம் (Male Deity)'));
      expect(VishnuMasterData.defaultRelationship, contains('காக்கும்'));
    });

    test('Verify exact 18 canonical Vishnu Names & Titles with no duplicates', () {
      final names = VishnuMasterData.namesAndTitles;
      expect(names.length, equals(18));

      final expectedEnNames = [
        'Vishnu', 'Narayana', 'Hari', 'Vasudeva', 'Madhava', 'Govinda',
        'Damodara', 'Achyuta', 'Ananta', 'Padmanabha', 'Hrishikesha', 'Janardhana',
        'Trivikrama', 'Upendra', 'Purushottama', 'Sridhara', 'Keshava', 'Lakshminarayana'
      ];

      final actualEnNames = names.map((n) => n.nameEn).toList();
      for (final expected in expectedEnNames) {
        expect(actualEnNames, contains(expected), reason: 'Missing Vishnu name: $expected');
      }

      // Ensure no duplicates
      final uniqueEnNames = names.map((n) => n.nameEn.toLowerCase()).toSet();
      expect(uniqueEnNames.length, equals(18));
    });

    test('Verify exact 10 Dashavatara avatars (kept separate from other forms)', () {
      final avatars = VishnuMasterData.dashavatara;
      expect(avatars.length, equals(10));

      final expectedAvatars = [
        'Matsya', 'Kurma', 'Varaha', 'Narasimha', 'Vamana',
        'Parashurama', 'Rama', 'Krishna', 'Buddha', 'Kalki'
      ];

      for (int i = 0; i < expectedAvatars.length; i++) {
        expect(avatars[i].nameEn, equals(expectedAvatars[i]));
        expect(avatars[i].type, equals('Dashavatara'));
        expect(avatars[i].id, equals(i + 1));
      }
    });

    test('Verify exact 11 Additional Vishnu Temple Forms', () {
      final forms = VishnuMasterData.additionalForms;
      expect(forms.length, equals(11));

      final expectedForms = [
        'Ananta Padmanabha', 'Lakshmi Narayana', 'Yoga Narasimha',
        'Ugra Narasimha', 'Shanta Narasimha', 'Hayagriva', 'Dhanvantari',
        'Jagannatha', 'Ranganatha', 'Venkateswara', 'Badri Narayana'
      ];

      final actualForms = forms.map((f) => f.nameEn).toList();
      for (final expected in expectedForms) {
        expect(actualForms, contains(expected), reason: 'Missing Vishnu form: $expected');
      }

      for (final f in forms) {
        expect(f.type, equals('Temple Form'));
      }
    });

    test('Ensure Dashavatara and Additional Temple Forms do NOT overlap or mix', () {
      final avatarNames = VishnuMasterData.dashavatara.map((a) => a.nameEn).toSet();
      final formNames = VishnuMasterData.additionalForms.map((f) => f.nameEn).toSet();

      final intersection = avatarNames.intersection(formNames);
      expect(intersection, isEmpty, reason: 'Dashavatara and Additional Forms must be separate!');

      final avatarIds = VishnuMasterData.dashavatara.map((a) => a.id).toSet();
      final formIds = VishnuMasterData.additionalForms.map((f) => f.id).toSet();
      expect(avatarIds.intersection(formIds), isEmpty);
    });

    test('Verify Vishnu Associated Consort Deities are separate from forms', () {
      final consorts = VishnuMasterData.associatedConsorts;
      expect(consorts, isNotEmpty);
      expect(consorts.any((c) => c.contains('மகாலட்சுமி') || c.contains('Mahalakshmi')), isTrue);
      expect(consorts.any((c) => c.contains('ஸ்ரீதேவி') || c.contains('Sridevi')), isTrue);
      expect(consorts.any((c) => c.contains('பூதேவி') || c.contains('Bhudevi')), isTrue);
      expect(consorts.any((c) => c.contains('ஆண்டாள்') || c.contains('Andal')), isTrue);

      // Verify consorts are NOT present in forms or avatars
      final allFormNames = [
        ...VishnuMasterData.dashavatara.map((f) => f.nameTa),
        ...VishnuMasterData.additionalForms.map((f) => f.nameTa),
      ];
      expect(allFormNames.contains('ஸ்ரீதேவி'), isFalse);
      expect(allFormNames.contains('பூதேவி'), isFalse);
    });
  });

  group('3. Murugan Master Data Verification', () {
    test('Default Gender, Parent Deity, and Relationship', () {
      expect(MuruganMasterData.defaultGender, equals('ஆண் தெய்வம் (Male Deity)'));
      expect(MuruganMasterData.defaultParentDeity, contains('சிவபெருமான் & பார்வதி தேவி'));
      expect(MuruganMasterData.defaultRelationship, contains('தந்தை & தாய்'));
    });

    test('Verify exact 13 canonical Murugan Names & Titles with no duplicates', () {
      final names = MuruganMasterData.namesAndTitles;
      expect(names.length, equals(13));

      final expectedEnNames = [
        'Murugan', 'Subrahmanya', 'Kartikeya', 'Skanda', 'Shanmukha',
        'Arumugam', 'Saravanabhava', 'Kumara', 'Guha', 'Senthil',
        'Velayudhan', 'Devasenapati', 'Swaminatha'
      ];

      final actualEnNames = names.map((n) => n.nameEn).toList();
      for (final expected in expectedEnNames) {
        expect(actualEnNames, contains(expected), reason: 'Missing Murugan name: $expected');
      }

      final uniqueEnNames = names.map((n) => n.nameEn.toLowerCase()).toSet();
      expect(uniqueEnNames.length, equals(13));
    });

    test('Verify exact 9 Murugan Temple Forms', () {
      final forms = MuruganMasterData.templeForms;
      expect(forms.length, equals(9));

      final expectedForms = [
        'Dandayudhapani', 'Palaniandavar', 'Swaminathaswamy', 'Shanmukha',
        'Subrahmanya', 'Balasubrahmanya', 'Kartikeya', 'Velayudhaswamy', 'Arumuga Perumal'
      ];

      final actualForms = forms.map((f) => f.nameEn).toList();
      for (final expected in expectedForms) {
        expect(actualForms, contains(expected), reason: 'Missing Murugan temple form: $expected');
      }

      for (final f in forms) {
        expect(f.type, equals('Temple Form'));
      }
    });

    test('Verify Murugan Consorts (Valli & Deivanai) are stored separately from forms', () {
      final consorts = MuruganMasterData.associatedConsorts;
      expect(consorts.length, equals(3));
      expect(consorts.any((c) => c.contains('வள்ளி') || c.contains('Valli')), isTrue);
      expect(consorts.any((c) => c.contains('தெய்வானை') || c.contains('Deivanai')), isTrue);

      // Verify Valli and Deivanai are NOT in Murugan forms
      final formNames = MuruganMasterData.templeForms.map((f) => f.nameEn).toList();
      expect(formNames.contains('Valli'), isFalse);
      expect(formNames.contains('Deivanai'), isFalse);
      expect(formNames.contains('Devasena'), isFalse);
    });
  });

  group('4. Vinayagar Master Data Verification', () {
    test('Default Gender, Parent Deity, and Relationship', () {
      expect(VinayagarMasterData.defaultGender, equals('ஆண் தெய்வம் (Male Deity)'));
      expect(VinayagarMasterData.defaultParentDeity, contains('சிவபெருமான் & பார்வதி தேவி'));
      expect(VinayagarMasterData.defaultRelationship, contains('தந்தை & தாய்'));
    });

    test('Verify exact 10 canonical Vinayagar Names & Titles with no duplicates', () {
      final names = VinayagarMasterData.namesAndTitles;
      expect(names.length, equals(10));

      final expectedEnNames = [
        'Vinayagar', 'Ganesha', 'Ganapati', 'Pillaiyar', 'Vighneshwara',
        'Gajanana', 'Ekadanta', 'Lambodara', 'Heramba', 'Ganesh'
      ];

      final actualEnNames = names.map((n) => n.nameEn).toList();
      for (final expected in expectedEnNames) {
        expect(actualEnNames, contains(expected), reason: 'Missing Vinayagar name: $expected');
      }

      final uniqueEnNames = names.map((n) => n.nameEn.toLowerCase()).toSet();
      expect(uniqueEnNames.length, equals(10));
    });

    test('Verify exact 32 Traditional Ganesha Forms', () {
      final forms = VinayagarMasterData.traditional32Forms;
      expect(forms.length, equals(32));

      // Verify numbering 1 to 32
      for (int i = 0; i < 32; i++) {
        expect(forms[i].id, equals(i + 1));
        expect(forms[i].type, equals('Traditional 32 Forms'));
        expect(forms[i].nameTa, isNotEmpty);
        expect(forms[i].nameEn, isNotEmpty);
        expect(forms[i].description, isNotEmpty);
      }

      // Check key forms from requirements
      final formNames = forms.map((f) => f.nameEn).toList();
      expect(formNames, contains('Bala Ganapati'));
      expect(formNames, contains('Taruna Ganapati'));
      expect(formNames, contains('Bhakta Ganapati'));
      expect(formNames, contains('Veera Ganapati'));
      expect(formNames, contains('Shakti Ganapati'));
      expect(formNames, contains('Maha Ganapati'));
      expect(formNames, contains('Nritya Ganapati'));
      expect(formNames, contains('Ekadanta Ganapati'));
      expect(formNames, contains('Sankatahara Ganapati'));
    });

    test('Verify Vinayagar Consorts (Siddhi & Buddhi) are stored separately from forms', () {
      final consorts = VinayagarMasterData.associatedConsorts;
      expect(consorts.any((c) => c.contains('சித்தி') || c.contains('Siddhi')), isTrue);
      expect(consorts.any((c) => c.contains('புத்தி') || c.contains('Buddhi')), isTrue);

      // Verify consorts are NOT forms
      final formNames = VinayagarMasterData.traditional32Forms.map((f) => f.nameEn).toList();
      expect(formNames.contains('Siddhi'), isFalse);
      expect(formNames.contains('Buddhi'), isFalse);
    });
  });
}
